"""
ML Scoring Admin Configuration
================================
Admin interface for viewing vocal analysis results.
"""

from django.contrib import admin
from .models import ScoreResult


@admin.register(ScoreResult)
class ScoreResultAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'recording', 'overall', 'pitch_score',
        'timing_score', 'tempo_score', 'volume_score',
        'grade', 'created_at',
    )
    list_filter = ('created_at',)
    search_fields = (
        'recording__user__username',
        'recording__song__title',
    )
    readonly_fields = (
        'recording', 'overall', 'pitch_score', 'timing_score',
        'tempo_score', 'volume_score', 'feedback', 'created_at',
    )
    ordering = ('-created_at',)

    def grade(self, obj):
        """Display letter grade based on overall score."""
        if obj.overall >= 90:
            return '⭐ A+'
        elif obj.overall >= 80:
            return 'A'
        elif obj.overall >= 70:
            return 'B'
        elif obj.overall >= 60:
            return 'C'
        elif obj.overall >= 50:
            return 'D'
        else:
            return 'F'
    grade.short_description = 'Grade'
