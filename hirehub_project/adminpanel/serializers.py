from rest_framework import serializers
from .models import PlatformSettings, CustomUser

class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'mobile_number', 'full_name', 'user_type', 'is_active']

class ApplicantSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    username = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['username', 'mobile_number', 'password']
 
    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            username=validated_data['username'],
            mobile_number=validated_data['mobile_number'],
            password=validated_data['password'],
            user_type='applicant'
        )
        # Explicitly create profile at registration time
        from moderator.models import ApplicantProfile
        ApplicantProfile.objects.get_or_create(user=user)
        return user

class PlatformSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlatformSettings
        fields = '__all__'
        

class RecruiterRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    username = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['username', 'mobile_number', 'password']

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            username=validated_data['username'],
            mobile_number=validated_data['mobile_number'],
            password=validated_data['password'],
            user_type='recruiter'
        )
        # Explicitly create default company profile at registration time
        from moderator.models import CompanyProfile
        if not CompanyProfile.objects.filter(user=user).exists():
            CompanyProfile.objects.create(
                user=user,
                company_name=f"{validated_data['username']} Company"
            )
        return user
