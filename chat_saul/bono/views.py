from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from .models import Case, Lawyer
from .serializers import CaseSerializer, LawyerSerializer
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from rest_framework.exceptions import ValidationError
from .models import CaseDocument



class CreateCaseView(generics.CreateAPIView):
    serializer_class = CaseSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        # Check for duplicates
        title = serializer.validated_data.get('title')
        description = serializer.validated_data.get('description')
        category = serializer.validated_data.get('category')

        if Case.objects.filter(user=self.request.user, title=title, description=description, category=category).exists():
            raise ValidationError({"detail": "A case with the same information already exists."})

        # Save the Case
        case = serializer.save(user=self.request.user)

        # Handle uploaded documents
        documents = self.request.FILES.getlist('documents')  # Get all uploaded documents
        for document in documents:
            CaseDocument.objects.create(case=case, file=document)


# Update a case
class UpdateCaseView(generics.UpdateAPIView):
    queryset = Case.objects.all()
    serializer_class = CaseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Ensure users can only update their own cases
        return Case.objects.filter(user=self.request.user)


# Delete a case
class DeleteCaseView(generics.DestroyAPIView):
    queryset = Case.objects.all()
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Ensure users can only delete their own cases
        return Case.objects.filter(user=self.request.user)


# Get a case by ID
class GetCaseByIdView(generics.RetrieveAPIView):
    queryset = Case.objects.all()
    serializer_class = CaseSerializer
    permission_classes = [IsAuthenticated]


# List all cases (optional: filter by user)
class ListCasesView(generics.ListAPIView):
    serializer_class = CaseSerializer
    permission_classes = [permissions.AllowAny]  # Allow public access

    def get_queryset(self):
        user_id = self.request.query_params.get('user_id', None)
        if user_id:
            return Case.objects.filter(user_id=user_id)
        return Case.objects.all()


# List all lawyers
class ListLawyersView(generics.ListAPIView):
    queryset = Lawyer.objects.all()
    serializer_class = LawyerSerializer
    permission_classes = [permissions.AllowAny]  # Allow public access


# Get a lawyer by ID
class GetLawyerByIdView(generics.RetrieveAPIView):
    queryset = Lawyer.objects.all()
    serializer_class = LawyerSerializer
    permission_classes = [permissions.AllowAny]  # Allow public access


