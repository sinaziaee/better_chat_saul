from django.contrib import admin
from .models import ContentCategory, Learn, Quiz, Content, UserGameInfo

admin.site.register(ContentCategory)
admin.site.register(Learn)
admin.site.register(Quiz)
admin.site.register(Content)
admin.site.register(UserGameInfo)
