"""
Studio Models
==============
Recording model for user vocal captures.
Schema matches BACKEND_STRUCTURE.md.
"""

from django.conf import settings
from django.db import models


class Recording(models.Model):
    """
    A user's vocal recording for a specific song.

    The audio file is stored locally (MEDIA_ROOT) or on Cloudflare R2.
    The audio_key field holds the storage path/key.

    Fields:
        user        FK(User)    — The recording user
        song        FK(Song)    — The song being performed
        audio_key   str         — Storage path for the recording audio file
        duration    float       — Recording duration in seconds
        created_at  datetime    — When the recording was made
    """
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='recordings',
    )
    song = models.ForeignKey(
        'catalog.Song',
        on_delete=models.CASCADE,
        related_name='recordings',
    )
    audio_key = models.CharField(
        max_length=500,
        help_text='Storage path for the recording audio file',
    )
    duration = models.FloatField(
        help_text='Recording duration in seconds',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'studio_recording'
        ordering = ['-created_at']
        verbose_name = 'Recording'
        verbose_name_plural = 'Recordings'

    def __str__(self):
        return f"{self.user.username} — {self.song.title} ({self.created_at:%Y-%m-%d})"
