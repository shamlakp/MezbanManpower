from django.urls import path
# pyrefly: ignore [missing-import]
from . import views
from rest_framework.routers import DefaultRouter

app_name = 'moderator'

from django.shortcuts import redirect

urlpatterns = [
    path('', lambda r: redirect('admin:index'), name='homepage_redirect'),
    path('verify/<uidb64>/<token>/', views.verify_email, name='verify_email'),
]

router = DefaultRouter()
router.register(r'api/companies', views.CompanyViewSet)
router.register(r'api/jobs', views.JobPostViewSet)
router.register(r'api/applications', views.JobApplicationViewSet, basename='jobapplication')

urlpatterns += router.urls

# Applicant API
urlpatterns += [
    path('api/applicant/register/', views.ApplicantRegisterAPI.as_view(), name='api_applicant_register'),
    path('api/applicant/profile/', views.ApplicantProfileAPI.as_view(), name='api_applicant_profile'),
    path('api/recruiter/profile/', views.RecruiterProfileAPI.as_view(), name='api_recruiter_profile'),
    path('api/logout/', views.LogoutAPI.as_view(), name='api_logout'),
]
