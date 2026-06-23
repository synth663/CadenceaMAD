"""
Studio Admin Configuration
============================
Admin interface for viewing and managing user recordings.
"""

from django.contrib import admin
from .models import Recording


@admin.register(Recording)
class RecordingAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'song', 'duration_display', 'has_score', 'created_at')
    list_filter = ('created_at', 'song__genre')
    search_fields = ('user__username', 'song__title')
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)

    def duration_display(self, obj):
        mins = int(obj.duration // 60)
        secs = int(obj.duration % 60)
        return f'{mins}:{secs:02d}'
    duration_display.short_description = 'Duration'

    def has_score(self, obj):
        try:
            return obj.score_result is not None
        except Exception:
            return False
    has_score.boolean = True
    has_score.short_description = 'Scored'
