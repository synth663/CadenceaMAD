"""
Cadencea URL Configuration
===========================
Root URL router for the Cadencea Django REST API.

Endpoints:
    /admin/            — Django admin console
    /auth/             — Authentication (register, login, logout, refresh, me)
    /api/songs/        — Song catalog
    /api/genres/       — Genre listing
    /api/recordings/   — User recordings
    /api/score/        — ML vocal scoring
"""

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # Django Admin
    path('admin/', admin.site.urls),

    # Authentication
    path('auth/', include('authentication.urls')),

    # API endpoints
    path('api/', include('catalog.urls')),
    path('api/', include('studio.urls')),
    path('api/', include('ml_scoring.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
