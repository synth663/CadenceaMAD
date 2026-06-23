"""
Authentication Serializers
===========================
Handles registration, login, and user profile serialization.
Response format matches the API contract in BACKEND_STRUCTURE.md.
"""

from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.db.models import Avg, Count
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User


class RegisterSerializer(serializers.Serializer):
    """
    POST /auth/register/
    Validates and creates a new user account, returning user + JWT tokens.
    """
    username = serializers.CharField(max_length=150, min_length=3)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)

    def validate_username(self, value):
        if User.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError('This username is already taken.')
        return value

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return value.lower()

    def validate_password(self, value):
        # Run Django's built-in password validators
        validate_password(value)
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            role=User.Role.USER,
        )
        return user

    def to_representation(self, user):
        refresh = RefreshToken.for_user(user)
        return {
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }
        }


class LoginSerializer(serializers.Serializer):
    """
    POST /auth/login/
    Authenticates via email + password, returns user + JWT tokens.
    """
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email', '').lower()
        password = attrs.get('password', '')

        # Authenticate using email (our USERNAME_FIELD)
        user = authenticate(
            request=self.context.get('request'),
            email=email,
            password=password,
        )

        if not user:
            # Check if user exists but password is wrong vs user doesn't exist
            if not User.objects.filter(email=email).exists():
                raise serializers.ValidationError(
                    {'detail': 'Invalid email or password.'}
                )
            raise serializers.ValidationError(
                {'detail': 'Invalid email or password.'}
            )


        if not user.is_active:
            raise serializers.ValidationError(
                {'detail': 'This account has been deactivated.'}
            )

        attrs['user'] = user
        return attrs

    def to_representation(self, validated_data):
        user = validated_data['user']
        refresh = RefreshToken.for_user(user)
        return {
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }
        }


class LogoutSerializer(serializers.Serializer):
    """
    POST /auth/logout/
    Blacklists the provided refresh token.
    """
    refresh = serializers.CharField()

    def validate(self, attrs):
        self._token = attrs['refresh']
        return attrs

    def save(self, **kwargs):
        try:
            token = RefreshToken(self._token)
            token.blacklist()
        except Exception:
            raise serializers.ValidationError(
                {'detail': 'Token is invalid or already blacklisted.'}
            )


class UserSerializer(serializers.ModelSerializer):
    """
    User profile data (used in register/login responses and GET /auth/me/).
    """
    stats = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'stats']
        read_only_fields = ['id', 'role']

    def get_stats(self, user):
        """Aggregate user performance statistics from recordings and scores."""
        from studio.models import Recording
        from ml_scoring.models import ScoreResult

        recordings_count = Recording.objects.filter(user=user).count()

        # Average overall score across all scored recordings
        avg_score = ScoreResult.objects.filter(
            recording__user=user
        ).aggregate(avg=Avg('overall'))['avg']

        # Achievement count based on score milestones
        achievements_count = self._count_achievements(user, recordings_count, avg_score)

        return {
            'average_score': round(avg_score) if avg_score else 0,
            'recordings_count': recordings_count,
            'achievements_count': achievements_count,
        }

    def _count_achievements(self, user, recordings_count, avg_score):
        """Calculate unlocked achievements based on user activity."""
        from ml_scoring.models import ScoreResult

        achievements = 0

        # "First Session" — at least 1 recording
        if recordings_count >= 1:
            achievements += 1

        # "Dedicated Singer" — 5+ recordings
        if recordings_count >= 5:
            achievements += 1

        # "Prolific Performer" — 20+ recordings
        if recordings_count >= 20:
            achievements += 1

        # "Pitch Perfect" — any recording scored 95+
        if ScoreResult.objects.filter(
            recording__user=user, overall__gte=95
        ).exists():
            achievements += 1

        # "Consistent Performer" — 5+ recordings with score >= 80
        if ScoreResult.objects.filter(
            recording__user=user, overall__gte=80
        ).count() >= 5:
            achievements += 1

        # "Rising Star" — average score >= 85
        if avg_score and avg_score >= 85:
            achievements += 1

        return achievements
