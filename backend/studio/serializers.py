"""
Studio Serializers
===================
Serializers for recording list view and file upload.
"""

import os
import uuid
from django.conf import settings
from rest_framework import serializers

from .models import Recording
from catalog.serializers import _get_media_url


class RecordingListSerializer(serializers.ModelSerializer):
    """
    Recording representation for list views.
    Includes song metadata and score summary.
    """
    song_title = serializers.CharField(source='song.title', read_only=True)
    artist_name = serializers.CharField(source='song.artist.name', read_only=True)
    audio_url = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()

    class Meta:
        model = Recording
        fields = [
            'id', 'song_title', 'artist_name', 'created_at',
            'duration', 'audio_url', 'score',
        ]

    def get_audio_url(self, recording):
        return _get_media_url(recording.audio_key, self.context.get('request'))

    def get_score(self, recording):
        """Fetch associated ScoreResult if it exists."""
        try:
            result = recording.score_result
            return {
                'overall': result.overall,
                'pitch': result.pitch_score,
                'timing': result.timing_score,
                'tempo': result.tempo_score,
                'volume': result.volume_score,
            }
        except Exception:
            return None


class RecordingUploadSerializer(serializers.Serializer):
    """
    POST /api/recordings/upload/

    Handles multipart file upload of a user recording.
    """
    song_id = serializers.IntegerField()
    duration = serializers.FloatField()
    audio_file = serializers.FileField()

    def validate_song_id(self, value):
        from catalog.models import Song
        if not Song.objects.filter(pk=value).exists():
            raise serializers.ValidationError('Song not found.')
        return value

    def validate_audio_file(self, value):
        # Validate file size (max 50MB)
        max_size = 50 * 1024 * 1024
        if value.size > max_size:
            raise serializers.ValidationError('Audio file must be under 50MB.')

        # Validate file type
        allowed_types = [
            'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav',
            'audio/m4a', 'audio/mp4', 'audio/aac', 'audio/ogg',
            'audio/webm', 'application/octet-stream',
        ]
        if value.content_type not in allowed_types:
            raise serializers.ValidationError(
                f'Unsupported audio format: {value.content_type}'
            )

        return value

    def create(self, validated_data):
        user = self.context['request'].user
        song_id = validated_data['song_id']
        duration = validated_data['duration']
        audio_file = validated_data['audio_file']

        # Generate a unique filename
        ext = os.path.splitext(audio_file.name)[1] or '.mp3'
        filename = f"recordings/{user.id}_{uuid.uuid4().hex[:8]}{ext}"

        if settings.STORAGE_BACKEND == 'r2':
            audio_key = self._upload_to_r2(audio_file, filename)
        else:
            audio_key = self._save_locally(audio_file, filename)

        recording = Recording.objects.create(
            user=user,
            song_id=song_id,
            audio_key=audio_key,
            duration=duration,
        )

        return recording

    def _save_locally(self, audio_file, filename):
        """Save the uploaded file to the local media directory."""
        filepath = os.path.join(settings.MEDIA_ROOT, filename)
        os.makedirs(os.path.dirname(filepath), exist_ok=True)

        with open(filepath, 'wb+') as destination:
            for chunk in audio_file.chunks():
                destination.write(chunk)

        return filename

    def _upload_to_r2(self, audio_file, filename):
        """Upload the file to Cloudflare R2."""
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

        client.upload_fileobj(
            audio_file,
            r2['BUCKET_NAME'],
            filename,
            ExtraArgs={'ContentType': audio_file.content_type},
        )

        return filename
