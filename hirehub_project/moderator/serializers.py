from rest_framework import serializers
from .models import CompanyProfile, JobPost

class CompanyProfileSerializer(serializers.ModelSerializer):
    logo = serializers.ImageField(required=False, allow_null=True, use_url=False)

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        if instance.logo:
            ret['logo'] = '/media/' + instance.logo.name.replace('\\\\', '/')
            ret['profile_image'] = ret['logo']
        else:
            ret['logo'] = None
            ret['profile_image'] = None
        return ret

    class Meta:
        model = CompanyProfile
        fields = '__all__'
        read_only_fields = ['user']

class JobPostSerializer(serializers.ModelSerializer):
    company_name = serializers.CharField(source='company.company_name', read_only=True)
    image = serializers.ImageField(required=False, allow_null=True, use_url=False)

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        if instance.image:
            ret['image'] = '/media/' + instance.image.name.replace('\\\\', '/')
        return ret

    class Meta:
        model = JobPost
        fields = ['id', 'company', 'position', 'company_name', 'no_of_vacancies', 'location', 'salary', 'is_approved', 'image', 'created_at', 'working_time', 'working_days', 'responsibilities', 'qualifications', 'benefits', 'annual_leave', 'industry', 'accommodation', 'meals', 'category']


class ApplicantProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    # Write: accept file upload. Read: return relative path.
    resume = serializers.FileField(required=False, allow_null=True, use_url=False)
    profile_image = serializers.ImageField(required=False, allow_null=True, use_url=False)

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        # Ensure profile_image and resume return relative paths (/media/...)
        if instance.profile_image:
            ret['profile_image'] = '/media/' + instance.profile_image.name.replace('\\\\', '/')
        if instance.resume:
            ret['resume'] = '/media/' + instance.resume.name.replace('\\\\', '/')
        return ret

    class Meta:
        from .models import ApplicantProfile
        model = ApplicantProfile
        fields = ['user', 'username', 'email', 'full_name', 'phone', 'resume', 'bio', 'skills', 'profile_image']
        read_only_fields = ['user']

    def update(self, instance, validated_data):
        # ImageField and FileField in validated_data will handle the files
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
