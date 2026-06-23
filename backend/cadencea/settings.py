"""
Cadencea Django Settings
========================
Django 5.0.6 backend for the Cadencea karaoke mobile application.

Configuration via environment variables (loaded from .env by python-dotenv).
"""

import os
from pathlib import Path
from datetime import timedelta

# ─────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent

# Load .env
try:
    from dotenv import load_dotenv
    load_dotenv(BASE_DIR / '.env')
except ImportError:
    pass

# ─────────────────────────────────────────────
# Core Settings
# ─────────────────────────────────────────────
SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-dev-key-change-in-production')
DEBUG = os.getenv('DEBUG', 'True').lower() in ('true', '1', 'yes')
ALLOWED_HOSTS = [h.strip() for h in os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')]

# ─────────────────────────────────────────────
# Installed Apps
# ─────────────────────────────────────────────
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',

    # Local apps
    'authentication',
    'catalog',
    'studio',
    'ml_scoring',
]

# ─────────────────────────────────────────────
# Middleware
# ─────────────────────────────────────────────
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'cadencea.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'cadencea.wsgi.application'

# ─────────────────────────────────────────────
# Database
# ─────────────────────────────────────────────
DATABASE_URL = os.getenv('DATABASE_URL', '')

if DATABASE_URL:
    # PostgreSQL for production
    # Format: postgres://user:pass@host:port/dbname
    import re
    match = re.match(
        r'postgres(?:ql)?://(?P<user>[^:]+):(?P<password>[^@]+)@(?P<host>[^:]+):(?P<port>\d+)/(?P<name>.+)',
        DATABASE_URL
    )
    if match:
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': match.group('name'),
                'USER': match.group('user'),
                'PASSWORD': match.group('password'),
                'HOST': match.group('host'),
                'PORT': match.group('port'),
            }
        }
    else:
        raise ValueError(f"Invalid DATABASE_URL format: {DATABASE_URL}")
else:
    # SQLite for local development
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# ─────────────────────────────────────────────
# Custom User Model
# ─────────────────────────────────────────────
AUTH_USER_MODEL = 'authentication.User'

# ─────────────────────────────────────────────
# Password Validation (Django PBKDF2 default)
# ─────────────────────────────────────────────
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 8}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ─────────────────────────────────────────────
# Django REST Framework
# ─────────────────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 50,
    'DEFAULT_RENDERER_CLASSES': (
        'rest_framework.renderers.JSONRenderer',
    ),
}

# ─────────────────────────────────────────────
# SimpleJWT Configuration
# ─────────────────────────────────────────────
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(
        minutes=int(os.getenv('JWT_ACCESS_LIFETIME_MINUTES', '30'))
    ),
    'REFRESH_TOKEN_LIFETIME': timedelta(
        days=int(os.getenv('JWT_REFRESH_LIFETIME_DAYS', '7'))
    ),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# ─────────────────────────────────────────────
# CORS Configuration
# ─────────────────────────────────────────────
cors_origins = os.getenv('CORS_ALLOWED_ORIGINS', 'http://localhost:3000,http://localhost:8080')
CORS_ALLOWED_ORIGINS = [o.strip() for o in cors_origins.split(',') if o.strip()]
CORS_ALLOW_ALL_ORIGINS = DEBUG  # Allow all in debug mode for Flutter dev
CORS_ALLOW_CREDENTIALS = True

# ─────────────────────────────────────────────
# Static & Media Files
# ─────────────────────────────────────────────
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# ─────────────────────────────────────────────
# Cloudflare R2 Configuration (S3-compatible)
# ─────────────────────────────────────────────
STORAGE_BACKEND = os.getenv('STORAGE_BACKEND', 'local')  # 'local' or 'r2'

R2_CONFIG = {
    'ACCOUNT_ID': os.getenv('R2_ACCOUNT_ID', ''),
    'ACCESS_KEY_ID': os.getenv('R2_ACCESS_KEY_ID', ''),
    'SECRET_ACCESS_KEY': os.getenv('R2_SECRET_ACCESS_KEY', ''),
    'BUCKET_NAME': os.getenv('R2_BUCKET_NAME', 'cadencea-media'),
    'PUBLIC_URL': os.getenv('R2_PUBLIC_URL', ''),
    'ENDPOINT_URL': f"https://{os.getenv('R2_ACCOUNT_ID', '')}.r2.cloudflarestorage.com",
    'SIGNED_URL_EXPIRY': 900,  # 15 minutes
}

# ─────────────────────────────────────────────
# External API Configuration
# ─────────────────────────────────────────────
EXTERNAL_APIS = {
    'MUSICBRAINZ': {
        'BASE_URL': 'https://musicbrainz.org/ws/2',
        'USER_AGENT': os.getenv(
            'MUSICBRAINZ_USER_AGENT',
            'Cadencea/1.0.0 (dev@cadencea.io)'
        ),
        'RATE_LIMIT': 1.0,  # seconds between requests
    },
    'COVER_ART_ARCHIVE': {
        'BASE_URL': 'https://coverartarchive.org',
    },
    'LRCLIB': {
        'BASE_URL': os.getenv('LRCLIB_BASE_URL', 'https://lrclib.net'),
    },
    'JAMENDO': {
        'BASE_URL': 'https://api.jamendo.com/v3.0',
        'CLIENT_ID': os.getenv('JAMENDO_CLIENT_ID', ''),
    },
}

# ─────────────────────────────────────────────
# Internationalization
# ─────────────────────────────────────────────
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# ─────────────────────────────────────────────
# Default primary key field type
# ─────────────────────────────────────────────
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ─────────────────────────────────────────────
# ML Scoring Configuration
# ─────────────────────────────────────────────
ML_SCORING = {
    'SAMPLE_RATE': 22050,        # Hz — librosa default
    'HOP_LENGTH': 512,           # frames — pitch resolution
    'FMIN': 65.0,                # Hz — lowest expected pitch (C2)
    'FMAX': 2093.0,              # Hz — highest expected pitch (C7)
    'PITCH_TOLERANCE': 0.5,      # semitones — tolerance for "perfect" pitch
    'SCORING_TIMEOUT': 30,       # seconds — max scoring time before timeout
}
