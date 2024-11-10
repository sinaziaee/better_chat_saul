from django.urls import path
from .views import ListChatSessionsView, CreateChatSessionView, UploadFileView, DeleteChatSessionView
from . import views

urlpatterns = [
    path('chat_sessions/', ListChatSessionsView.as_view(), name='list_chat_sessions'),
    path('chat_sessions/create/', CreateChatSessionView.as_view(), name='create_chat_session'),
    path('chat_sessions/<int:session_id>/', DeleteChatSessionView.as_view(), name='delete_chat_session'),
    path('upload_file/', UploadFileView.as_view(), name='upload_file'),
]
