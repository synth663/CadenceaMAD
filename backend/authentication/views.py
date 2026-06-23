"""
Authentication Views
=====================
REST endpoints for user registration, login, logout, token refresh, and profile.
All response formats match the API contract in BACKEND_STRUCTURE.md.
"""

from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenRefreshView

from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    LogoutSerializer,
    UserSerializer,
)


class RegisterView(GenericAPIView):
    """
    POST /auth/register/

    Creates a new user account and returns user data + JWT tokens.
    No authentication required.
    """
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(
            serializer.to_representation(user),
            status=status.HTTP_201_CREATED,
        )


class LoginView(GenericAPIView):
    """
    POST /auth/login/

    Authenticates user with email + password, returns user data + JWT tokens.
    No authentication required.
    """
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(
            data=request.data,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)
        return Response(
            serializer.to_representation(serializer.validated_data),
            status=status.HTTP_200_OK,
        )


class LogoutView(GenericAPIView):
    """
    POST /auth/logout/

    Blacklists the provided refresh token to invalidate the session.
    Requires authentication.
    """
    serializer_class = LogoutSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(status=status.HTTP_205_RESET_CONTENT)


class MeView(GenericAPIView):
    """
    GET /auth/me/

    Returns the authenticated user's profile data and performance statistics.
    Requires authentication.
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)


# Token refresh uses the built-in SimpleJWT view
class CustomTokenRefreshView(TokenRefreshView):
    """
    POST /auth/token/refresh/

    Accepts a refresh token, returns a new access token.
    The old refresh token is rotated and blacklisted (configured in settings).
    """
    pass
