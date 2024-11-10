from django.db import models
from django.dispatch import receiver
from django.conf import settings
import os

# Use settings.AUTH_USER_MODEL for compatibility with CustomUser
User = settings.AUTH_USER_MODEL


class Lawyer(models.Model):
    SPECIALIZATION_CHOICES = [
        ('Criminal Law', 'Criminal Law'),
        ('Family Law', 'Family Law'),
        ('Corporate Law', 'Corporate Law'),
        ('Intellectual Property', 'Intellectual Property'),
        ('Immigration Law', 'Immigration Law'),
        ('Labor Law', 'Labor Law'),
        ('Real Estate Law', 'Real Estate Law'),
        ('Tax Law', 'Tax Law'),
        ('Environmental Law', 'Environmental Law'),
        ('Health Law', 'Health Law'),
        ('Human Rights Law', 'Human Rights Law'),
        ('Contract Law', 'Contract Law'),
        ('International Law', 'International Law'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    bio = models.TextField(blank=True, null=True)
    specialization = models.CharField(
        max_length=255,
        choices=SPECIALIZATION_CHOICES,
        default='General Practice'
    )
    rating = models.FloatField(default=0.0)
    is_verified = models.BooleanField(default=False)
    profile_image = models.ImageField(
        upload_to='lawyer_images/', 
        blank=True, 
        null=True, 
        help_text='Upload a profile image for the lawyer'
    )

    def __str__(self):
        return self.user.email


class Case(models.Model):
    STATUS_CHOICES = [
        ('Open', 'Open'),
        ('Closed', 'Closed'),
        ('In Progress', 'In Progress'),
    ]

    CATEGORY_CHOICES = [
        ('Criminal', 'Criminal'),
        ('Family', 'Family'),
        ('Corporate', 'Corporate'),
        ('Intellectual Property', 'Intellectual Property'),
        ('Immigration', 'Immigration'),
        ('Labor', 'Labor'),
        ('Real Estate', 'Real Estate'),
        ('Tax', 'Tax'),
        ('Environmental', 'Environmental'),
        ('Health', 'Health'),
        ('Human Rights', 'Human Rights'),
        ('Contract', 'Contract'),
        ('International', 'International'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cases')
    title = models.CharField(max_length=255)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Open')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='Criminal')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class CaseDocument(models.Model):
    case = models.ForeignKey(Case, on_delete=models.CASCADE, related_name='documents')
    file = models.FileField(
        upload_to='case_documents/', 
        help_text='Upload a document related to the case'
    )
    name = models.CharField(max_length=255, blank=True, help_text='Name of the document')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Document for case: {self.case.title} - {self.name}"


# Signal to set the name field based on the uploaded file
@receiver(models.signals.post_save, sender=CaseDocument)
def set_document_name(sender, instance, created, **kwargs):
    if created and not instance.name:
        instance.name = os.path.basename(instance.file.name)
        instance.save()


class Application(models.Model):
    case = models.ForeignKey(Case, on_delete=models.CASCADE, related_name='applications')
    lawyer = models.ForeignKey(Lawyer, on_delete=models.CASCADE, related_name='applications')
    message = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0.0)
    is_accepted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Application for {self.case.title} by {self.lawyer.user.email}"


class PostTopic(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    title = models.CharField(max_length=255)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class Comment(models.Model):
    post = models.ForeignKey(PostTopic, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Comment by {self.user.email} on {self.post.title}"
