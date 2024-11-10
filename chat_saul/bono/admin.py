from django.contrib import admin
from .models import Lawyer, Case, CaseDocument, Application, PostTopic, Comment


# Register Lawyer
@admin.register(Lawyer)
class LawyerAdmin(admin.ModelAdmin):
    list_display = ['user', 'specialization', 'is_verified', 'rating']
    search_fields = ['user__email', 'specialization']
    list_filter = ['is_verified', 'specialization']


# Register Case
@admin.register(Case)
class CaseAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'status', 'category', 'created_at']
    search_fields = ['title', 'user__email', 'category']
    list_filter = ['status', 'category']
    ordering = ['-created_at']


# Register CaseDocument
@admin.register(CaseDocument)
class CaseDocumentAdmin(admin.ModelAdmin):
    list_display = ['case', 'name', 'uploaded_at']
    search_fields = ['case__title', 'name']
    ordering = ['-uploaded_at']


# Register Application
@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ['case', 'lawyer', 'is_accepted', 'price', 'created_at']
    search_fields = ['case__title', 'lawyer__user__email']
    list_filter = ['is_accepted']
    ordering = ['-created_at']


# Register PostTopic
@admin.register(PostTopic)
class PostTopicAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'created_at']
    search_fields = ['title', 'user__email']
    ordering = ['-created_at']


# Register Comment
@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['post', 'user', 'created_at']
    search_fields = ['post__title', 'user__email', 'content']
    ordering = ['-created_at']
