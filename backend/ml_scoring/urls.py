"""
ML Scoring URL Configuration
==============================
Scoring endpoint mounted under /api/ prefix.
"""

from django.urls import path
from .views import ScoreView

urlpatterns = [
    path('score/', ScoreView.as_view(), name='ml-score'),
]
