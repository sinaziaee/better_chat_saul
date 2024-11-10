# models.py

from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class ChatSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="chat_sessions", null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    session_name = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return f"ChatSession {self.id} - {self.session_name or 'Unnamed'}"

class ChatMessage(models.Model):
    SENDER_CHOICES = [
        ('user', 'User'),
        ('model', 'Bot'),
    ]

    chat_session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='messages')
    sender = models.CharField(max_length=10, choices=SENDER_CHOICES)
    text = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Session {self.chat_session.pk}, Chat {self.id}, {self.sender}, {get_time(self.timestamp)}, {self.text[:20]}"

def get_time(timesamp):
    return timesamp.strftime("%m-%d %H:%M:%S")

class ChatFile(models.Model):
    chat_session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='files')
    file = models.FileField(upload_to='chat_files/')
    file_type = models.CharField(max_length=50)  # e.g., 'document', 'image'
    uploaded_at = models.DateTimeField(auto_now_add=True)
    content = models.TextField(blank=True, null=True)  # Stores extracted text or image description

    def __str__(self):
        return f"File {self.id} in Session {self.chat_session.pk}, Type: {self.file_type}"
