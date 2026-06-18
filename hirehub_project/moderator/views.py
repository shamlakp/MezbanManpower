from django.shortcuts import render, redirect, reverse, get_object_or_404
from django.http import HttpResponse 
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.mail import send_mail
from django.contrib.auth.tokens import default_token_generator
from django.conf import settings
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
import logging

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, viewsets
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authentication import TokenAuthentication
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.exceptions import ValidationError, PermissionDenied

logger = logging.getLogger(__name__)

from .serializers import ApplicantProfileSerializer, CompanyProfileSerializer, JobApplicationSerializer, JobPostSerializer
from adminpanel.serializers import ApplicantSerializer

from .utils import get_dashboard_url, notify_admin_on_login
from .models import JobPost, CompanyProfile, ApplicantProfile, JobApplication 
from .forms import RecruiterForm, ApplicantForm, CompanyProfileForm, JobPostForm
from adminpanel.models import OTPVerification


# --- WE REMOVED ALL WEB UI VIEWS (HOMEPAGE, DASHBOARDS, FORMS) ---
# ONLY API AND VERIFICATION LOGIC REMAINS BELOW

User = get_user_model()

def verify_email(request, uidb64, token):
    User = get_user_model()
    try:
        uid = urlsafe_base64_decode(uidb64).decode()
        user = User.objects.get(pk=uid)
    except (TypeError, ValueError, OverflowError, User.DoesNotExist):
        user = None

    if user and default_token_generator.check_token(user, token):
        user.is_active = True
        user.save()
        return HttpResponse('Email verified successfully! You can now log in via the app.')
    else:
        return HttpResponse('Verification link is invalid or expired.', status=400)




class CompanyViewSet(viewsets.ModelViewSet):
    queryset = CompanyProfile.objects.all()
    serializer_class = CompanyProfileSerializer
    parser_classes = [MultiPartParser, FormParser]

class JobPostViewSet(viewsets.ModelViewSet):
    queryset = JobPost.objects.all().order_by('-created_at')
    serializer_class = JobPostSerializer
    authentication_classes = [TokenAuthentication]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticated()]
        return []

    def perform_create(self, serializer):
        print(f"DEBUG: JobPost create data: {self.request.data}")
        # Automatically assign the recruiter's company to the job post
        # If multiple companies, we should get the company_id from request data
        company_id = self.request.data.get('company')
        if not company_id:
            # Fallback to the first company if not specified (legacy behavior)
            company = CompanyProfile.objects.filter(user=self.request.user).first()
        else:
            company = CompanyProfile.objects.filter(id=company_id, user=self.request.user).first()

        if not company:
            raise ValidationError("You must choose a Company Profile you own before posting a job.")
        serializer.save(company=company)


class ApplicantRegisterAPI(APIView):
    def post(self, request):
        email = request.data.get('email')
        if email:
            otp_obj = OTPVerification.objects.filter(email=email).first()
            if not otp_obj or not otp_obj.is_verified:
                return Response({"error": "Please verify your email with an OTP first."}, status=status.HTTP_400_BAD_REQUEST)

        serializer = ApplicantSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.is_active = True
            user.save()
            if email and otp_obj:
                otp_obj.delete()
            return Response({"message": "Registration successful. You can log in immediately."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LogoutAPI(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            # Clear Django session if exists (important for web)
            logout(request)
            
            # Delete DRF token safely
            if request.auth:
                request.auth.delete()
                
            return Response({"message": "Successfully logged out."}, status=status.HTTP_200_OK)
        except Exception as e:
            # Log the error for the developer but don't 500
            print(f"Logout Error: {e}")
            return Response({"error": "Logout failed or token already invalid"}, status=status.HTTP_400_BAD_REQUEST)


class ApplicantProfileAPI(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        profile, _ = ApplicantProfile.objects.get_or_create(user=request.user)
        serializer = ApplicantProfileSerializer(profile, context={'request': request})
        return Response(serializer.data)

    def patch(self, request):
        try:
            logger.info(f"ApplicantProfile Update attempt: User={request.user}, DataKeys={list(request.data.keys())}")
            profile, created = ApplicantProfile.objects.get_or_create(user=request.user)
            
            serializer = ApplicantProfileSerializer(profile, data=request.data, partial=True, context={'request': request})
            if serializer.is_valid():
                # Manually sync user fields if provided
                if 'full_name' in request.data:
                    full_name = request.data['full_name'].strip()
                    name_parts = full_name.split(' ', 1)
                    request.user.first_name = name_parts[0]
                    request.user.last_name = name_parts[1] if len(name_parts) > 1 else ''
                    request.user.save()

                # Sync file uploads manually for robustness with multipart/form-data
                if 'profile_image' in request.FILES:
                    profile.profile_image = request.FILES['profile_image']
                if 'resume' in request.FILES:
                    profile.resume = request.FILES['resume']

                serializer.save()
                logger.info(f"ApplicantProfile successfully updated for {request.user}")
                return Response(ApplicantProfileSerializer(profile, context={'request': request}).data, status=status.HTTP_200_OK)
            else:
                logger.warning(f"ApplicantProfile validation failed for {request.user}: {serializer.errors}")
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Critical error updating applicant profile for {request.user}: {str(e)}", exc_info=True)
            return Response({"error": "Failed to update profile", "detail": str(e)}, 
                          status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class RecruiterProfileAPI(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        companies = CompanyProfile.objects.filter(user=request.user)
        # If no companies exist, create a default one (fallback)
        if not companies.exists():
            default_company = CompanyProfile.objects.create(
                user=request.user,
                company_name=f"{request.user.username} Company"
            )
            companies = [default_company]
             
        serializer = CompanyProfileSerializer(companies, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        """Create a new company profile for this recruiter."""
        serializer = CompanyProfileSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request):
        """Update a specific company profile."""
        company_id = request.data.get('id')
        if not company_id:
            return Response({"error": "Company ID required"}, status=status.HTTP_400_BAD_REQUEST)
            
        company = get_object_or_404(CompanyProfile, id=company_id, user=request.user)
        serializer = CompanyProfileSerializer(company, data=request.data, partial=True)
        if serializer.is_valid():
            # Manual sync for better robustness with multipart data
            for field in ['company_name', 'website', 'head_office_address', 'recruiter_name', 'recruiter_contact']:
                if field in request.data:
                    setattr(company, field, request.data[field])
            
            if 'logo' in request.FILES:
                company.logo = request.FILES['logo']
            
            company.save()
            return Response(CompanyProfileSerializer(company, context={'request': request}).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        """Delete a specific company profile."""
        company_id = request.data.get('id')
        if not company_id:
            return Response({"error": "Company ID required"}, status=status.HTTP_400_BAD_REQUEST)
            
        company = get_object_or_404(CompanyProfile, id=company_id, user=request.user)
        company.delete()
        return Response({"message": "Company deleted"}, status=status.HTTP_200_OK)

class JobApplicationViewSet(viewsets.ModelViewSet):
    queryset = JobApplication.objects.all()
    serializer_class = JobApplicationSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'admin':
            return JobApplication.objects.all()
        elif user.user_type == 'recruiter':
            company = CompanyProfile.objects.filter(user=user).first()
            return JobApplication.objects.filter(job__company=company)
        elif user.user_type == 'applicant':
            applicant = ApplicantProfile.objects.filter(user=user).first()
            return JobApplication.objects.filter(applicant=applicant)
        return JobApplication.objects.none()

    def perform_create(self, serializer):
        print(f"DEBUG: JobApplication create data: {self.request.data}")
        applicant = ApplicantProfile.objects.filter(user=self.request.user).first()
        if not applicant:
            raise ValidationError("You must have an Applicant Profile to apply for a job.")
        
        # Check if already applied
        job_id = self.request.data.get('job')
        if JobApplication.objects.filter(applicant=applicant, job_id=job_id).exists():
            raise ValidationError("You have already applied for this job.")
            
        serializer.save(applicant=applicant)

    def perform_update(self, serializer):
        # Only recruiters and admins can change status
        user = self.request.user
        if user.user_type not in ['recruiter', 'admin']:
            raise PermissionDenied("Only recruiters or administrators can update application status.")
        serializer.save()
