"""
Catalog Models
===============
Artist, Song, and SongLyricLine models for the music catalog.
Schema matches BACKEND_STRUCTURE.md with additional fields for
external API integration (MusicBrainz IDs, license metadata).
"""

from django.db import models


class Artist(models.Model):
    """
    Musical artist / performer.

    Fields:
        name            str     — Unique artist name
        bio             text    — Optional biography
        musicbrainz_id  str     — MusicBrainz MBID (nullable, for API linking)
        image_url       str     — Artist image URL (from external source)
    """
    name = models.CharField(max_length=200, unique=True)
    bio = models.TextField(blank=True, default='')
    musicbrainz_id = models.CharField(
        max_length=36, blank=True, default='',
        help_text='MusicBrainz Artist MBID',
        db_index=True,
    )
    image_url = models.URLField(max_length=500, blank=True, default='')

    class Meta:
        db_table = 'catalog_artist'
        ordering = ['name']
        verbose_name = 'Artist'
        verbose_name_plural = 'Artists'

    def __str__(self):
        return self.name


class Song(models.Model):
    """
    A song in the karaoke catalog.

    Media files are stored either locally (MEDIA_ROOT) or on Cloudflare R2.
    The *_key fields hold the storage path/key for each media asset.

    Fields:
        title           str     — Song title
        artist          FK      — Artist who performs the song
        language        str     — Song language (default: English)
        genre           str     — Musical genre
        cover_key       str     — Storage key for album cover art
        audio_key       str     — Storage key for instrumental/karaoke track
        vocal_ref_key   str     — Storage key for reference vocal track
        lrc_key         str     — Storage key for synced LRC lyrics file
        duration        float   — Duration in seconds
        plays           int     — Total play count
        musicbrainz_id  str     — MusicBrainz Recording MBID
        license         str     — License type (e.g., 'CC-BY', 'All Rights Reserved')
        source_url      str     — Original source URL
        commercial_allowed bool — Whether commercial use is permitted
        created_at      datetime — When the song was added
    """
    title = models.CharField(max_length=200)
    artist = models.ForeignKey(
        Artist,
        on_delete=models.CASCADE,
        related_name='songs',
    )
    language = models.CharField(max_length=50, default='English')
    genre = models.CharField(max_length=100, db_index=True)

    # Media file storage keys (paths or R2 keys)
    cover_key = models.CharField(
        max_length=500, blank=True, default='',
        help_text='Storage path for cover art image',
    )
    audio_key = models.CharField(
        max_length=500, blank=True, default='',
        help_text='Storage path for instrumental/karaoke audio',
    )
    vocal_ref_key = models.CharField(
        max_length=500, blank=True, default='',
        help_text='Storage path for reference vocal track',
    )
    lrc_key = models.CharField(
        max_length=500, blank=True, default='',
        help_text='Storage path for synced LRC lyrics file',
    )

    duration = models.FloatField(
        default=0.0,
        help_text='Duration in seconds',
    )
    plays = models.PositiveIntegerField(default=0)

    # External API linkage
    musicbrainz_id = models.CharField(
        max_length=36, blank=True, default='',
        help_text='MusicBrainz Recording MBID',
        db_index=True,
    )

    # License metadata (per implementation plan recommendation)
    license = models.CharField(
        max_length=100, blank=True, default='All Rights Reserved',
        help_text='License type (e.g., CC-BY, CC-BY-NC)',
    )
    source_url = models.URLField(
        max_length=500, blank=True, default='',
        help_text='Original source URL for attribution',
    )
    commercial_allowed = models.BooleanField(
        default=False,
        help_text='Whether commercial use of this track is permitted',
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'catalog_song'
        ordering = ['-plays', 'title']
        verbose_name = 'Song'
        verbose_name_plural = 'Songs'

    def __str__(self):
        return f"{self.title} — {self.artist.name}"


class SongLyricLine(models.Model):
    """
    A single timestamped lyric line for a song.

    Used for synced karaoke display. Lines are ordered by timestamp.
    When word-level timing is available (enhanced LRC), the `words` JSON
    field stores per-word start/end times.

    Fields:
        song        FK      — Parent song
        timestamp   float   — Seconds from song start
        end_timestamp float — End time for this line (seconds)
        text        str     — Lyric text content
        words       JSON    — Optional word-level timing data
    """
    song = models.ForeignKey(
        Song,
        on_delete=models.CASCADE,
        related_name='lyrics',
    )
    timestamp = models.FloatField(
        help_text='Start time in seconds from song start',
    )
    end_timestamp = models.FloatField(
        default=0.0,
        help_text='End time in seconds (0 = until next line)',
    )
    text = models.CharField(max_length=500)
    words = models.JSONField(
        blank=True, null=True,
        help_text='Optional word-level timing: [{"word": "Hello", "start": 1.0, "end": 1.5}, ...]',
    )

    class Meta:
        db_table = 'catalog_songlyricline'
        ordering = ['song', 'timestamp']
        verbose_name = 'Lyric Line'
        verbose_name_plural = 'Lyric Lines'
        indexes = [
            models.Index(fields=['song', 'timestamp'], name='idx_lyric_song_time'),
        ]

    def __str__(self):
        return f"[{self.timestamp:.2f}s] {self.text[:50]}"
