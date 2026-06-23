"""
ML Scoring Serializers
========================
Request/response serialization for the scoring endpoint.
"""

from rest_framework import serializers
from .models import ScoreResult


class ScoreRequestSerializer(serializers.Serializer):
    """
    POST /api/score/

    Request body: { "recording_id": 45 }
    Validates that the recording exists and belongs to the authenticated user.
    """
    recording_id = serializers.IntegerField()

    def validate_recording_id(self, value):
        from studio.models import Recording

        try:
            recording = Recording.objects.select_related('song').get(pk=value)
        except Recording.DoesNotExist:
            raise serializers.ValidationError('Recording not found.')

        # Check ownership
        request = self.context.get('request')
        if request and recording.user != request.user:
            raise serializers.ValidationError('You can only score your own recordings.')

        # Check if already scored
        if ScoreResult.objects.filter(recording=recording).exists():
            raise serializers.ValidationError(
                'This recording has already been scored. '
                'Each recording can only be scored once.'
            )

        # Check that the song has a vocal reference track
        if not recording.song.vocal_ref_key:
            raise serializers.ValidationError(
                'Cannot score: the song does not have a vocal reference track.'
            )

        self._recording = recording
        return value

    @property
    def recording(self):
        return self._recording


class ScoreResultSerializer(serializers.ModelSerializer):
    """Response serializer for score results."""
    recording_id = serializers.IntegerField(source='recording.id')

    class Meta:
        model = ScoreResult
        fields = [
            'recording_id', 'overall', 'pitch_score',
            'timing_score', 'tempo_score', 'volume_score',
            'feedback', 'created_at',
        ]
