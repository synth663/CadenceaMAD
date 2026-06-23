"""
Studio Views
==============
REST endpoints for user recording management.

    GET  /api/recordings/          — List current user's recordings
    POST /api/recordings/upload/   — Upload a new recording
"""

from rest_framework import status
from rest_framework.generics import ListAPIView, GenericAPIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Recording
from .serializers import RecordingListSerializer, RecordingUploadSerializer


class RecordingListView(ListAPIView):
    """
    GET /api/recordings/

    List all recordings for the authenticated user.
    Includes song metadata and score summaries.
    """
    serializer_class = RecordingListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return (
            Recording.objects
            .filter(user=self.request.user)
            .select_related('song', 'song__artist')
            .order_by('-created_at')
        )


class RecordingUploadView(GenericAPIView):
    """
    POST /api/recordings/upload/

    Upload a recording file (multipart form data).
    Accepts: song_id, duration, audio_file (binary).
    """
    serializer_class = RecordingUploadSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        serializer = self.get_serializer(
            data=request.data,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)
        recording = serializer.save()

        return Response(
            {
                'id': recording.id,
                'song_id': recording.song_id,
                'duration': recording.duration,
                'audio_key': recording.audio_key,
                'created_at': recording.created_at.isoformat(),
            },
            status=status.HTTP_201_CREATED,
        )
