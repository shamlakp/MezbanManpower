from rest_framework import serializers
from .models import CompanyProfile, JobPost

class CompanyProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CompanyProfile
        fields = '__all__'
        read_only_fields = ['user']

class JobPostSerializer(serializers.ModelSerializer):
    company_name = serializers.CharField(source='company.company_name', read_only=True)
    
    class Meta:
        model = JobPost
        fields = ['id', 'company', 'position', 'company_name', 'no_of_vacancies', 'location', 'salary', 'is_approved', 'image', 'created_at', 'working_time', 'working_days', 'responsibilities', 'qualifications', 'benefits', 'annual_leave', 'industry', 'accommodation', 'meals', 'category']


class ApplicantProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    resume = serializers.FileField(required=False, allow_null=True)

    class Meta:
        from .models import ApplicantProfile
        model = ApplicantProfile
        fields = ['user', 'username', 'email', 'full_name', 'phone', 'resume', 'bio', 'skills']
        read_only_fields = ['user']

    def update(self, instance, validated_data):
        # Handle file fields separately to ensure they are updated correctly
        resume = validated_data.pop('resume', None)
        if resume is not None:
             instance.resume = resume
            
        return super().update(instance, validated_data)


class JobApplicationSerializer(serializers.ModelSerializer):
    job_position = serializers.CharField(source='job.position', read_only=True)
    company_name = serializers.CharField(source='job.company.company_name', read_only=True)
    applicant_name = serializers.CharField(source='applicant.user.username', read_only=True)
    applicant_details = ApplicantProfileSerializer(source='applicant', read_only=True)
    job_details = serializers.SerializerMethodField()

    class Meta:
        model = None
        fields = '__all__'
        read_only_fields = ['applied_at', 'applicant']

    def __init__(self, *args, **kwargs):
        from .models import JobApplication
        self.Meta.model = JobApplication
        super().__init__(*args, **kwargs)

    def get_job_details(self, obj):
        return {
            'id': obj.job.id,
            'title': obj.job.position,
            'company_name': obj.job.company.company_name,
            'location': obj.job.location,
            'salary': obj.job.salary,
        }
