from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import ChatSession, ChatFile
from django.http import JsonResponse
from rest_framework.parsers import MultiPartParser, FormParser
from django.conf import settings
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync


class ListChatSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user  # Get the authenticated user from the token
        sessions = ChatSession.objects.filter(user=user).values("id", "session_name", "created_at")
        return Response(sessions)


class CreateChatSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user  # Authenticated user
        session_name = request.data.get("session_name", "Unnamed Session")  # Optional session name

        # Create a new chat session
        chat_session = ChatSession.objects.create(user=user, session_name=session_name)

        # Return the session ID and other details
        return Response({
            "id": chat_session.id,
            "session_name": chat_session.session_name,
            "created_at": chat_session.created_at,
        }, status=status.HTTP_201_CREATED)


class DeleteChatSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, session_id):
        """
        Delete a chat session and all associated files.
        """
        try:
            # Retrieve the session and ensure it belongs to the authenticated user
            chat_session = ChatSession.objects.get(id=session_id, user=request.user)
            # Delete all associated files
            ChatFile.objects.filter(chat_session=chat_session).delete()
            # Delete the chat session
            chat_session.delete()
            return Response({"status": "success", "message": "Chat session deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        except ChatSession.DoesNotExist:
            return Response({"status": "error", "message": "Chat session not found or access denied."}, status=status.HTTP_404_NOT_FOUND)


class UploadFileView(APIView):
    permission_classes = [IsAuthenticated]  # Require authentication
    parser_classes = [MultiPartParser, FormParser]  # For handling file uploads

    def post(self, request, format=None):
        session_id = request.data.get('session_id')
        file_type = request.data.get('file_type', 'unknown')

        # Validate session_id
        if not session_id:
            return Response({'status': 'error', 'message': 'Session ID is required'}, status=status.HTTP_400_BAD_REQUEST)

        # Get the chat session, ensuring it's associated with the authenticated user
        try:
            chat_session = ChatSession.objects.get(id=session_id, user=request.user)
        except ChatSession.DoesNotExist:
            return Response({'status': 'error', 'message': 'Chat session does not exist or access denied'}, status=status.HTTP_404_NOT_FOUND)

        # Get the uploaded file
        uploaded_file = request.FILES.get('file')
        if not uploaded_file:
            return Response({'status': 'error', 'message': 'No file provided'}, status=status.HTTP_400_BAD_REQUEST)

        # Save the file
        chat_file = ChatFile.objects.create(chat_session=chat_session, file=uploaded_file, file_type=file_type)

        # Notify the WebSocket consumers about the uploaded file
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'chat_{session_id}',  # The group name should match the one used in ChatConsumer
            {
                'type': 'file_uploaded',
                'file_id': chat_file.id,
                'file_type': file_type,
            }
        )

        return Response({'status': 'success', 'file_id': chat_file.id}, status=status.HTTP_200_OK)
