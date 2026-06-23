"""
Studio URL Configuration
=========================
Recording endpoints mounted under /api/ prefix.
"""

from django.urls import path
from .views import RecordingListView, RecordingUploadView

urlpatterns = [
    path('recordings/', RecordingListView.as_view(), name='recording-list'),
    path('recordings/upload/', RecordingUploadView.as_view(), name='recording-upload'),
]
