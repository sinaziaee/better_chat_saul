from rest_framework import serializers
from .models import Lawyer, Case, Application, PostTopic, Comment, CaseDocument
from users.models import CustomUser

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser  # This refers to your `CustomUser` model
        fields = ['id', 'email', 'is_lawyer']  # Include relevant fields


class LawyerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lawyer
        fields = ['id', 'user', 'bio', 'specialization', 'is_verified', 'profile_image', 'rating']
        depth = 1


class CaseDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = CaseDocument
        fields = ['id', 'file', 'name', 'uploaded_at']


class CaseSerializer(serializers.ModelSerializer):
    documents = CaseDocumentSerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)  # Optional: Nested user serializer

    class Meta:
        model = Case
        fields = ['id', 'user', 'title', 'description', 'status', 'category', 'created_at', 'documents']
        read_only_fields = ['created_at'] 


class ApplicationSerializer(serializers.ModelSerializer):
    lawyer = LawyerSerializer(read_only=True)  # Replace `user` with `lawyer`

    class Meta:
        model = Application
        fields = ['id', 'case', 'lawyer', 'message', 'price', 'is_accepted', 'created_at']
        read_only_fields = ['is_accepted', 'created_at']


class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = PostTopic  # Updated to `PostTopic` as per your model
        fields = ['id', 'user', 'title', 'content', 'created_at']
        read_only_fields = ['created_at']


class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ['id', 'post', 'user', 'content', 'created_at']
        read_only_fields = ['created_at']