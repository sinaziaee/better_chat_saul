from django.urls import path
from .views import (
    ContentCategoryListAPIView,
    ContentListCreateAPIView,
    ContentRetrieveAPIView,
    LearnListCreateAPIView,
    LearnRetrieveAPIView,
    QuizListCreateAPIView,
    QuizRetrieveAPIView,
    UserGameInfoRetrieveUpdateAPIView,
    UserAvailableLearnContentsAPIView,
    UserSeenContentsAPIView
)
from . import views

urlpatterns = [
    path('categories/', ContentCategoryListAPIView.as_view(), name='category-list'),
    path('contents/', ContentListCreateAPIView.as_view(), name='content-list-create'),
    path('contents/<int:pk>/', ContentRetrieveAPIView.as_view(), name='content-detail'),
    path('learns/', LearnListCreateAPIView.as_view(), name='learn-list-create'),
    path('learns/<int:pk>/', LearnRetrieveAPIView.as_view(), name='learn-detail'),
    path('quizzes/', QuizListCreateAPIView.as_view(), name='quiz-list-create'),
    path('quizzes/<int:pk>/', QuizRetrieveAPIView.as_view(), name='quiz-detail'),
    path('users/game-info/', UserGameInfoRetrieveUpdateAPIView.as_view(), name='user-game-info'),
    path('users/<int:user_id>/available-learn-contents/', UserAvailableLearnContentsAPIView.as_view(), name='user-available-learn-contents'),
    path('users/seen-contents/', UserSeenContentsAPIView.as_view(), name='user-seen-contents'),
    path('contents/create-content/', views.create_content, name='create-content'),
]

