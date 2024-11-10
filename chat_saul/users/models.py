from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    is_lawyer = models.BooleanField(default=False)  # Add the is_lawyer field

    def __str__(self):
        return self.username
