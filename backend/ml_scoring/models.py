"""
ML Scoring Models
==================
ScoreResult model for storing vocal analysis results.
Schema matches BACKEND_STRUCTURE.md.
"""

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class ScoreResult(models.Model):
    """
    ML vocal analysis result for a user recording.

    Stores per-category scores (0-100) and textual feedback.
    One-to-one relationship with Recording (each recording gets one score).

    Fields:
        recording       FK(Recording)   — The analyzed recording (unique)
        overall         int (0-100)     — Weighted overall score
        pitch_score     int (0-100)     — Pitch accuracy score
        timing_score    int (0-100)     — Temporal alignment score
        tempo_score     int (0-100)     — Speed consistency score
        volume_score    int (0-100)     — Dynamics control score
        feedback        text            — NLP-generated textual feedback
        created_at      datetime        — When scoring was completed
    """
    recording = models.OneToOneField(
        'studio.Recording',
        on_delete=models.CASCADE,
        related_name='score_result',
    )
    overall = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Weighted overall score (0-100)',
    )
    pitch_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Pitch accuracy (0-100)',
    )
    timing_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Timing precision (0-100)',
    )
    tempo_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Tempo consistency (0-100)',
    )
    volume_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Volume/dynamics control (0-100)',
    )
    feedback = models.TextField(
        help_text='NLP-generated textual feedback',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ml_scoreresult'
        verbose_name = 'Score Result'
        verbose_name_plural = 'Score Results'

    def __str__(self):
        return f"Score: {self.overall}/100 — {self.recording}"
