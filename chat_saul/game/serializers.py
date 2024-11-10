from rest_framework import serializers
from .models import ContentCategory, Content, Learn, Quiz, UserGameInfo
from django.contrib.auth.models import User

class ContentCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentCategory
        fields = '__all__'

class LearnSerializer(serializers.ModelSerializer):
    class Meta:
        model = Learn
        fields = '__all__'

class LimitedLearnSerializer(serializers.ModelSerializer):
    class Meta:
        model = Learn
        fields = ['id']

class LimitedQuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz
        fields = ['id']

class QuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz
        fields = '__all__'

    def validate(self, data):
        if not data.get('option1') or not data.get('option2'):
            raise serializers.ValidationError("Option1 and Option2 are required.")
        options = [
            data.get('option1'),
            data.get('option2'),
            data.get('option3'),
            data.get('option4')
        ]
        options = [opt for opt in options if opt]
        if data['answer'] not in options:
            raise serializers.ValidationError("Answer must be one of the provided options.")
        return data

class ContentSerializer(serializers.ModelSerializer):
    learns = LimitedLearnSerializer(many=True, read_only=True, required=False, default=[])
    quizzes = LimitedQuizSerializer(many=True, read_only=True, required=False, default=[])
    
    # learns = LearnSerializer(many=True, read_only=True)
    # quizzes = QuizSerializer(many=True, read_only=True)

    class Meta:
        model = Content
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class UserGameInfoSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    # learned_contents = serializers.SerializerMethodField()
    learned_contents = ContentSerializer(many=True, read_only=True)

    class Meta:
        model = UserGameInfo
        fields = ['user', 'points', 'coins', 'learned_contents']

    # def get_learned_contents(self, obj):
    #     if obj.learned_contents.exists():
    #         return ContentSerializer(obj.learned_contents.all(), many=True).data
    #     return []
