from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import generics, status, permissions
from rest_framework.decorators import permission_classes
from .models import ContentCategory, Content, Learn, Quiz, UserGameInfo
from .serializers import (
    ContentCategorySerializer,
    ContentSerializer,
    LearnSerializer,
    QuizSerializer,
    UserGameInfoSerializer,
)
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view

# allow everyone to access this view
@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def create_content(request):
    try:
        # Extract data from request
        data = request.data
        category_id = data.get('category_id')  # Assume this is sent from frontend
        
        # Create Content instance
        content = Content.objects.create(
            title=f"Generated Content {Content.objects.count() + 1}"  # You can modify this title
        )
        
        # Add category
        category = get_object_or_404(ContentCategory, id=category_id)
        content.categories.add(category)
        
        # Create Learn instances
        for material in data['learning_materials']:
            Learn.objects.create(
                title=material['title'],
                content=material['content'],
                parent_content=content
            )
        
        # Create Quiz instances
        for quiz_data in data['quizzes']:
            # Convert string answer to integer (assuming answer comes as "Option X")
            answer_number = int(quiz_data['answer'].split()[-1])
            
            Quiz.objects.create(
                question=quiz_data['question'],
                option1=quiz_data['option1'],
                option2=quiz_data['option2'],
                option3=quiz_data['option3'],
                option4=quiz_data['option4'],
                answer=answer_number,
                point=int(quiz_data['points']),
                parent_content=content
            )
        
        return Response({
            'status': 'success',
            'message': 'Content created successfully',
            'content_id': content.id
        })
        
    except Exception as e:
        return Response({
            'status': 'error',
            'message': str(e)
        }, status=400)

# ContentCategory Views
class ContentCategoryListAPIView(generics.ListAPIView):
    queryset = ContentCategory.objects.all()
    serializer_class = ContentCategorySerializer
    # permit everyone to access this view
    permission_classes = [permissions.AllowAny]

# Content Views
class ContentListCreateAPIView(generics.ListCreateAPIView):
    queryset = Content.objects.all()
    serializer_class = ContentSerializer
    depth = 1

class ContentRetrieveAPIView(generics.RetrieveAPIView):
    queryset = Content.objects.all()
    print("hereee")
    serializer_class = ContentSerializer

# Learn Views
class LearnListCreateAPIView(generics.ListCreateAPIView):
    queryset = Learn.objects.all()
    print("hereee2")
    serializer_class = LearnSerializer

class LearnRetrieveAPIView(generics.RetrieveAPIView):
    queryset = Learn.objects.all()
    serializer_class = LearnSerializer

# Quiz Views
class QuizListCreateAPIView(generics.ListCreateAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

class QuizRetrieveAPIView(generics.RetrieveAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

# User Game Info Views
class UserGameInfoRetrieveUpdateAPIView(APIView):
    def get(self, request):
        try:
            user_id = request.user.id
            user_game_info = UserGameInfo.objects.get(user__id=user_id)
            print("UserGameInfo Retrieved:", user_game_info)
            print(user_game_info.learned_contents.all())
            print(user_game_info.user.id)
            serializer = UserGameInfoSerializer(user_game_info)
            print("Serialized Data:", serializer.data)
            return Response(serializer.data)
        except UserGameInfo.DoesNotExist:
            return Response({"error": "UserGameInfo not found", "points": 0}, status=202)
        except Exception as e:
            print("Error:", str(e))
            return Response({"error": "Something went wrong"}, status=500)

    def patch(self, request):
        try:
            user_id = request.user.id
            user_game_info = UserGameInfo.objects.get(user__id=user_id)
            serializer = UserGameInfoSerializer(user_game_info, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                print("meeeeeeeeeee")
                # return Response(serializer.data)
                return Response({"good": "UserGameInfo saved"}, status=200)
            return Response(serializer.errors, status=400)
        except UserGameInfo.DoesNotExist:
            return Response({"error": "UserGameInfo not found"}, status=202)
        except Exception as e:
            print("-------------------  ")
            print(e)
            return Response({"error": "Something went wrong"}, status=500)

class UserAvailableLearnContentsAPIView(APIView):
    def get(self, request, user_id):
        try:
            user_game_info = UserGameInfo.objects.get(user__id=user_id)
            learned_content_ids = user_game_info.learned_contents.values_list('id', flat=True)
            available_contents = Content.objects.exclude(id__in=learned_content_ids)
            serializer = ContentSerializer(available_contents, many=True)
            return Response(serializer.data)
        except UserGameInfo.DoesNotExist:
            return Response({"error": "UserGameInfo not found"}, status=404)

class UserSeenContentsAPIView(APIView):
    def get(self, request):
        try:
            user_id = request.user.id
            user_game_info = UserGameInfo.objects.get(user_id=user_id)
            seen_content_ids = user_game_info.learned_contents.values_list('id', flat=True)
            seen_contents = Content.objects.filter(id__in=seen_content_ids)
            serializer = ContentSerializer(seen_contents, many=True)
            return Response(serializer.data)
        except UserGameInfo.DoesNotExist:
            return Response({"error": "UserGameInfo not found"}, status=202)
        except Exception as e:
            print("-------------------  ")
            print(e)
            return Response({"error": "Something went wrong"}, status=500)
