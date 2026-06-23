"""
ML Scoring Views
==================
REST endpoint for vocal analysis scoring.

    POST /api/score/   — Analyze a recording and return scores
"""

import os
import logging
from django.conf import settings
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import ScoreResult
from .serializers import ScoreRequestSerializer, ScoreResultSerializer

logger = logging.getLogger(__name__)


class ScoreView(GenericAPIView):
    """
    POST /api/score/

    Triggers ML vocal analysis for a user recording.

    Flow:
    1. Validate recording_id (exists, belongs to user, has vocal ref)
    2. Locate user recording audio file
    3. Locate reference vocal track for the song
    4. Run the scoring pipeline (librosa + DTW)
    5. Save ScoreResult to database
    6. Return scores + feedback

    Expected processing time: <5 seconds for a 3-minute song (per KPI).
    """
    serializer_class = ScoreRequestSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(
            data=request.data,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)

        recording = serializer.recording
        song = recording.song

        # Resolve file paths
        user_audio_path = self._resolve_path(recording.audio_key)
        ref_audio_path = self._resolve_path(song.vocal_ref_key)

        # Verify files exist
        if not os.path.exists(user_audio_path):
            return Response(
                {'detail': f'User recording audio file not found at {recording.audio_key}'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if not os.path.exists(ref_audio_path):
            return Response(
                {'detail': f'Reference vocal track not found at {song.vocal_ref_key}'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Run the scoring pipeline
        try:
            from .scorer import score_recording

            scores = score_recording(
                user_audio_path=user_audio_path,
                ref_audio_path=ref_audio_path,
            )

        except Exception as e:
            logger.error(f"Scoring pipeline failed for recording {recording.id}: {e}")
            return Response(
                {'detail': f'Scoring failed: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        # Save score result
        score_result = ScoreResult.objects.create(
            recording=recording,
            overall=scores['overall'],
            pitch_score=scores['pitch_score'],
            timing_score=scores['timing_score'],
            tempo_score=scores['tempo_score'],
            volume_score=scores['volume_score'],
            feedback=scores['feedback'],
        )

        # Return response
        response_serializer = ScoreResultSerializer(score_result)
        return Response(response_serializer.data, status=status.HTTP_200_OK)

    def _resolve_path(self, key: str) -> str:
        """
        Resolve a storage key to an absolute file path.
        For local storage: prepends MEDIA_ROOT.
        For R2: would download to a temp file (future).
        """
        if settings.STORAGE_BACKEND == 'r2':
            return self._download_from_r2(key)
        else:
            return os.path.join(settings.MEDIA_ROOT, key)

    def _download_from_r2(self, key: str) -> str:
        """
        Download a file from R2 to a temporary local path for processing.
        Returns the local path.
        """
        import tempfile
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

        # Download to temp file
        _, ext = os.path.splitext(key)
        tmp = tempfile.NamedTemporaryFile(suffix=ext, delete=False)
        client.download_file(r2['BUCKET_NAME'], key, tmp.name)
        tmp.close()

        return tmp.name
