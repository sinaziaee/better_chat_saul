from django.contrib.auth.models import User
from django.db import models
from django.core.exceptions import ValidationError


from django.conf import settings

User = settings.AUTH_USER_MODEL

class ContentCategory(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Content(models.Model):
    title = models.CharField(max_length=255)
    categories = models.ManyToManyField(ContentCategory, related_name='contents')

    def __str__(self):
        return self.title

class Learn(models.Model):
    image = models.ImageField(upload_to='learn_images/', null=True, blank=True)
    content = models.TextField(max_length=600)
    title = models.CharField(max_length=255)
    parent_content = models.ForeignKey(Content, on_delete=models.CASCADE, related_name='learns')

    def __str__(self):
        return self.title

class Quiz(models.Model):
    question = models.CharField(max_length=255)
    option1 = models.CharField(max_length=255)
    option2 = models.CharField(max_length=255)
    option3 = models.CharField(max_length=255, null=True, blank=True)
    option4 = models.CharField(max_length=255, null=True, blank=True)
    answer = models.PositiveSmallIntegerField(choices=[
        (1, 'Option 1'),
        (2, 'Option 2'),
        (3, 'Option 3'),
        (4, 'Option 4')
    ])
    point = models.IntegerField()
    parent_content = models.ForeignKey(Content, on_delete=models.CASCADE, related_name='quizzes')

    def __str__(self):
        return self.question

    def clean(self):
        """Ensure the answer corresponds to a valid option."""
        if self.answer == 3 and not self.option3:
            raise ValidationError("Answer cannot be 'Option 3' because it is not provided.")
        if self.answer == 4 and not self.option4:
            raise ValidationError("Answer cannot be 'Option 4' because it is not provided.")

class UserGameInfo(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='game_info')
    points = models.IntegerField(default=0)
    coins = models.IntegerField(default=0)
    learned_contents = models.ManyToManyField(Content, related_name='learned_by', blank=True)

    def __str__(self):
        return f"{self.user.id}, {self.user.username}'s Game Info"
