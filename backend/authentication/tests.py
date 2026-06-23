"""
Authentication API Tests
=========================
Tests for register, login, logout, token refresh, and profile endpoints.
"""

from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status

from authentication.models import User


class RegisterTests(TestCase):
    """Test POST /auth/register/"""

    def setUp(self):
        self.client = APIClient()
        self.url = reverse('auth-register')

    def test_register_success(self):
        data = {
            'username': 'newuser',
            'email': 'new@cadencea.io',
            'password': 'SecurePass123!',
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('user', response.data)
        self.assertIn('tokens', response.data)
        self.assertEqual(response.data['user']['username'], 'newuser')
        self.assertEqual(response.data['user']['email'], 'new@cadencea.io')
        self.assertEqual(response.data['user']['role'], 'user')
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])

    def test_register_duplicate_email(self):
        User.objects.create_user(
            username='existing', email='dup@cadencea.io', password='Pass123!'
        )
        data = {
            'username': 'newuser2',
            'email': 'dup@cadencea.io',
            'password': 'SecurePass123!',
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_register_weak_password(self):
        data = {
            'username': 'weakuser',
            'email': 'weak@cadencea.io',
            'password': '123',
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class LoginTests(TestCase):
    """Test POST /auth/login/"""

    def setUp(self):
        self.client = APIClient()
        self.url = reverse('auth-login')
        self.user = User.objects.create_user(
            username='loginuser',
            email='login@cadencea.io',
            password='LoginPass123!',
        )

    def test_login_success(self):
        data = {'email': 'login@cadencea.io', 'password': 'LoginPass123!'}
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('user', response.data)
        self.assertIn('tokens', response.data)
        self.assertEqual(response.data['user']['email'], 'login@cadencea.io')

    def test_login_wrong_password(self):
        data = {'email': 'login@cadencea.io', 'password': 'WrongPass'}
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_nonexistent_email(self):
        data = {'email': 'noone@cadencea.io', 'password': 'Whatever123!'}
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class MeTests(TestCase):
    """Test GET /auth/me/"""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='meuser',
            email='me@cadencea.io',
            password='MePass123!',
        )
        # Login to get token
        login_response = self.client.post(
            reverse('auth-login'),
            {'email': 'me@cadencea.io', 'password': 'MePass123!'},
            format='json',
        )
        self.token = login_response.data['tokens']['access']

    def test_me_authenticated(self):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        response = self.client.get(reverse('auth-me'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'meuser')
        self.assertEqual(response.data['email'], 'me@cadencea.io')
        self.assertIn('stats', response.data)

    def test_me_unauthenticated(self):
        response = self.client.get(reverse('auth-me'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class LogoutTests(TestCase):
    """Test POST /auth/logout/"""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='logoutuser',
            email='logout@cadencea.io',
            password='LogoutPass123!',
        )
        login_response = self.client.post(
            reverse('auth-login'),
            {'email': 'logout@cadencea.io', 'password': 'LogoutPass123!'},
            format='json',
        )
        self.access_token = login_response.data['tokens']['access']
        self.refresh_token = login_response.data['tokens']['refresh']

    def test_logout_success(self):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.access_token}')
        response = self.client.post(
            reverse('auth-logout'),
            {'refresh': self.refresh_token},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_205_RESET_CONTENT)
