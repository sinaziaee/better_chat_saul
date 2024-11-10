from django.urls import path

from .views import (
    CreateCaseView,
    UpdateCaseView,
    DeleteCaseView,
    GetCaseByIdView,
    ListCasesView,
    ListLawyersView,
    GetLawyerByIdView,
    # ApplicationDetailView,
    # ApplicationListView,
    # ApplicationCreateView,
    # ApplicationUpdateView,
)

urlpatterns = [
    # Case-related APIs
    path('cases/create/', CreateCaseView.as_view(), name='create-case'),
    path('cases/<int:pk>/update/', UpdateCaseView.as_view(), name='update-case'),
    path('cases/<int:pk>/delete/', DeleteCaseView.as_view(), name='delete-case'),
    path('cases/<int:pk>/', GetCaseByIdView.as_view(), name='get-case-by-id'),
    path('cases/', ListCasesView.as_view(), name='list-cases'),

    # Lawyer-related APIs
    path('lawyers/', ListLawyersView.as_view(), name='list-lawyers'),
    path('lawyers/<int:pk>/', GetLawyerByIdView.as_view(), name='get-lawyer-by-id'),
        
    # applications
    # path('applications/<int:pk>/', ApplicationDetailView.as_view(), name='application-detail'),
    # path('applications/', ApplicationListView.as_view(), name='application-list'),
    # path('applications/create/', ApplicationCreateView.as_view(), name='application-create'),
    # path('applications/<int:pk>/update/', ApplicationUpdateView.as_view(), name='application-update'),
]