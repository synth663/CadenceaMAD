"""
Catalog Serializers
====================
Serializers for songs, artists, lyrics, and genres.
Response formats match the API contract in BACKEND_STRUCTURE.md.
"""

import os
from django.conf import settings
from rest_framework import serializers

from .models import Artist, Song, SongLyricLine


class ArtistSerializer(serializers.ModelSerializer):
    """Minimal artist representation for song list views."""
    class Meta:
        model = Artist
        fields = ['id', 'name', 'bio']


class LyricLineSerializer(serializers.ModelSerializer):
    """
    Single lyric line with timing for synced display.
    Includes word-level timing when available.
    """
    class Meta:
        model = SongLyricLine
        fields = ['id', 'timestamp', 'end_timestamp', 'text', 'words']


class SongListSerializer(serializers.ModelSerializer):
    """
    Song representation for list views (dashboard, search results).
    Includes artist name, cover URL, audio URL, and lyrics.
    """
    artist = serializers.CharField(source='artist.name', read_only=True)
    cover_url = serializers.SerializerMethodField()
    audio_url = serializers.SerializerMethodField()
    lyrics = serializers.SerializerMethodField()

    class Meta:
        model = Song
        fields = [
            'id', 'title', 'artist', 'genre', 'language',
            'duration', 'plays', 'cover_url', 'audio_url', 'lyrics',
        ]

    def get_cover_url(self, song):
        """Generate a URL for the cover art."""
        return _get_media_url(song.cover_key, self.context.get('request'))

    def get_audio_url(self, song):
        return _get_media_url(song.audio_key, self.context.get('request'))

    def get_lyrics(self, song):
        """Return all lyric lines sorted by timestamp."""
        lyric_lines = song.lyrics.all().order_by('timestamp')
        return LyricLineSerializer(lyric_lines, many=True).data


class SongDetailSerializer(serializers.ModelSerializer):
    """
    Full song representation for the Now Playing screen.
    Includes signed media URLs and all synced lyrics.
    """
    artist = ArtistSerializer(read_only=True)
    cover_url = serializers.SerializerMethodField()
    audio_url = serializers.SerializerMethodField()
    vocal_ref_url = serializers.SerializerMethodField()
    lyrics = serializers.SerializerMethodField()

    class Meta:
        model = Song
        fields = [
            'id', 'title', 'artist', 'genre', 'language',
            'duration', 'plays', 'license', 'source_url', 'commercial_allowed',
            'cover_url', 'audio_url', 'vocal_ref_url', 'lyrics',
        ]

    def get_cover_url(self, song):
        return _get_media_url(song.cover_key, self.context.get('request'))

    def get_audio_url(self, song):
        return _get_media_url(song.audio_key, self.context.get('request'))

    def get_vocal_ref_url(self, song):
        return _get_media_url(song.vocal_ref_key, self.context.get('request'))

    def get_lyrics(self, song):
        """Return all lyric lines sorted by timestamp."""
        lyric_lines = song.lyrics.all().order_by('timestamp')
        return LyricLineSerializer(lyric_lines, many=True).data


class GenreSerializer(serializers.Serializer):
    """Genre name with active song count."""
    name = serializers.CharField()
    count = serializers.IntegerField()


class ExternalSearchResultSerializer(serializers.Serializer):
    """
    Unified search result combining local DB + external API results.
    Used for the /api/search/ broker endpoint.
    """
    source = serializers.CharField()  # 'local', 'musicbrainz', 'jamendo'
    mbid = serializers.CharField(allow_blank=True, default='')
    title = serializers.CharField()
    artist = serializers.CharField()
    duration = serializers.FloatField(default=0.0)
    cover_url = serializers.CharField(allow_blank=True, default='')
    has_synced_lyrics = serializers.BooleanField(default=False)
    local_id = serializers.IntegerField(allow_null=True, default=None)
    license = serializers.CharField(allow_blank=True, default='')


# ─── Helper Functions ───


def _get_media_url(key: str, request=None) -> str:
    """
    Generate a URL for a media file based on the storage backend.

    For local storage: returns a media URL path.
    For R2: would generate a signed URL (to be implemented when R2 is configured).
    """
    if not key:
        return ''

    if settings.STORAGE_BACKEND == 'r2':
        return _get_r2_signed_url(key)
    else:
        # Local storage: serve from MEDIA_URL
        if request:
            return request.build_absolute_uri(f'{settings.MEDIA_URL}{key}')
        return f'{settings.MEDIA_URL}{key}'


def _get_r2_signed_url(key: str) -> str:
    """
    Generate a signed URL for a Cloudflare R2 object.
    Uses boto3 with S3-compatible presigned URL generation.
    """
    try:
        import boto3
        from botocore.config import Config

        r2 = settings.R2_CONFIG

        client = boto3.client(
            's3',
            endpoint_url=r2['ENDPOINT_URL'],
            aws_access_key_id=r2['ACCESS_KEY_ID'],
            aws_secret_access_key=r2['SECRET_ACCESS_KEY'],
            config=Config(signature_version='s3v4'),
        )

        url = client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': r2['BUCKET_NAME'],
                'Key': key,
            },
            ExpiresIn=r2['SIGNED_URL_EXPIRY'],
        )
        return url

    except Exception as e:
        import logging
        logging.getLogger(__name__).error(f"R2 signed URL error for key '{key}': {e}")
        return ''
