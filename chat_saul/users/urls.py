from django.urls import path
from .views import SignupView, CustomLoginView, CheckEmailView

urlpatterns = [
    path('signup/', SignupView.as_view(), name='signup'),
    path('login/', CustomLoginView.as_view(), name='login'),
    path('check-email/', CheckEmailView.as_view(), name='check_email'),
]
