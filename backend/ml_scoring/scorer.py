"""
Vocal Scoring Engine
=====================
ML-powered vocal analysis using librosa for pitch extraction
and SciPy for Dynamic Time Warping (DTW) alignment.

This module compares a user's vocal recording against the original
reference vocal track to produce scores across 4 categories:
    - Pitch accuracy (fundamental frequency comparison)
    - Timing precision (onset alignment)
    - Tempo consistency (BPM stability)
    - Volume control (RMS energy dynamics)

No ML model training required — uses rule-based signal processing.
"""

import logging
import numpy as np
from django.conf import settings

logger = logging.getLogger(__name__)


def _get_ml_config():
    """Get ML scoring configuration from Django settings."""
    return settings.ML_SCORING


# ═══════════════════════════════════════════════
# 1. Audio Loading & Pitch Extraction
# ═══════════════════════════════════════════════

def load_audio(filepath: str, sr: int = None) -> tuple[np.ndarray, int]:
    """
    Load an audio file and return (samples, sample_rate).
    Converts to mono and resamples to the target rate.
    """
    import librosa

    config = _get_ml_config()
    target_sr = sr or config['SAMPLE_RATE']

    try:
        y, sr = librosa.load(filepath, sr=target_sr, mono=True)
        return y, sr
    except Exception as e:
        logger.error(f"Failed to load audio file '{filepath}': {e}")
        raise


def extract_pitch(y: np.ndarray, sr: int) -> np.ndarray:
    """
    Extract fundamental frequency (F0) using probabilistic YIN (pYIN).

    Returns an array of F0 values in Hz. Unvoiced frames are NaN.
    F0 is then converted to MIDI note numbers for scale-independent comparison.
    """
    import librosa

    config = _get_ml_config()

    f0, voiced_flag, voiced_probs = librosa.pyin(
        y,
        fmin=config['FMIN'],
        fmax=config['FMAX'],
        sr=sr,
        hop_length=config['HOP_LENGTH'],
    )

    return f0  # Hz values, NaN for unvoiced


def f0_to_midi(f0: np.ndarray) -> np.ndarray:
    """
    Convert F0 (Hz) to MIDI note numbers for pitch comparison.
    MIDI note = 69 + 12 * log2(f0 / 440)
    NaN values remain NaN.
    """
    import librosa
    return librosa.hz_to_midi(f0)


def clean_pitch(f0: np.ndarray) -> np.ndarray:
    """
    Clean pitch array by removing NaN (unvoiced) frames.
    Returns only voiced frames for comparison.
    """
    mask = ~np.isnan(f0)
    return f0[mask]


# ═══════════════════════════════════════════════
# 2. Dynamic Time Warping (DTW) Alignment
# ═══════════════════════════════════════════════

def align_dtw(user_pitch: np.ndarray, ref_pitch: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Align user and reference pitch sequences using Dynamic Time Warping.

    Uses SciPy's DTW implementation to find the optimal alignment
    between two pitch sequences of potentially different lengths.

    Returns:
        user_aligned: Aligned user pitch values
        ref_aligned: Aligned reference pitch values
        cost: Total DTW cost (lower = more similar)
    """
    from scipy.spatial.distance import cdist

    if len(user_pitch) == 0 or len(ref_pitch) == 0:
        return np.array([]), np.array([]), np.array([0.0])

    # Reshape for cdist
    user_2d = user_pitch.reshape(-1, 1)
    ref_2d = ref_pitch.reshape(-1, 1)

    # Compute cost matrix
    cost_matrix = cdist(user_2d, ref_2d, metric='euclidean')

    # Compute DTW using dynamic programming
    n, m = cost_matrix.shape
    dtw_matrix = np.full((n + 1, m + 1), np.inf)
    dtw_matrix[0, 0] = 0

    for i in range(1, n + 1):
        for j in range(1, m + 1):
            cost = cost_matrix[i - 1, j - 1]
            dtw_matrix[i, j] = cost + min(
                dtw_matrix[i - 1, j],      # insertion
                dtw_matrix[i, j - 1],      # deletion
                dtw_matrix[i - 1, j - 1],  # match
            )

    # Backtrack to find alignment path
    path_i, path_j = [], []
    i, j = n, m
    while i > 0 and j > 0:
        path_i.append(i - 1)
        path_j.append(j - 1)

        candidates = [
            (dtw_matrix[i - 1, j - 1], i - 1, j - 1),
            (dtw_matrix[i - 1, j], i - 1, j),
            (dtw_matrix[i, j - 1], i, j - 1),
        ]
        _, i, j = min(candidates, key=lambda x: x[0])

    path_i.reverse()
    path_j.reverse()

    user_aligned = user_pitch[path_i]
    ref_aligned = ref_pitch[path_j]
    total_cost = dtw_matrix[n, m]

    return user_aligned, ref_aligned, np.array([total_cost])


# ═══════════════════════════════════════════════
# 3. Scoring Functions
# ═══════════════════════════════════════════════

def score_pitch(user_midi: np.ndarray, ref_midi: np.ndarray) -> int:
    """
    Score pitch accuracy by comparing aligned MIDI note arrays.

    Compares frame-by-frame:
        ±0.5 semitone = perfect (no penalty)
        ±1.0 semitone = good (minor penalty)
        >2.0 semitone = poor (heavy penalty)

    Returns: score 0-100
    """
    if len(user_midi) == 0 or len(ref_midi) == 0:
        return 50  # Default when no pitched content detected

    # Align with DTW
    user_aligned, ref_aligned, _ = align_dtw(user_midi, ref_midi)

    if len(user_aligned) == 0:
        return 50

    # Calculate semitone differences
    diffs = np.abs(user_aligned - ref_aligned)

    config = _get_ml_config()
    tolerance = config['PITCH_TOLERANCE']  # 0.5 semitones

    # Score each frame
    frame_scores = np.zeros(len(diffs))
    for i, d in enumerate(diffs):
        if d <= tolerance:
            frame_scores[i] = 100.0  # Perfect
        elif d <= tolerance * 2:
            frame_scores[i] = 85.0   # Good
        elif d <= tolerance * 4:
            frame_scores[i] = 60.0   # Acceptable
        else:
            frame_scores[i] = max(0.0, 30.0 - d * 5.0)  # Poor

    score = int(np.clip(np.mean(frame_scores), 0, 100))
    return score


def score_timing(y_user: np.ndarray, y_ref: np.ndarray, sr: int) -> int:
    """
    Score timing precision by comparing onset detection patterns.

    Detects when notes begin in both tracks and measures
    how closely the user's note starts match the reference.

    Returns: score 0-100
    """
    import librosa

    config = _get_ml_config()

    try:
        # Detect onsets
        user_onsets = librosa.onset.onset_detect(
            y=y_user, sr=sr,
            hop_length=config['HOP_LENGTH'],
            units='time',
        )
        ref_onsets = librosa.onset.onset_detect(
            y=y_ref, sr=sr,
            hop_length=config['HOP_LENGTH'],
            units='time',
        )

        if len(user_onsets) == 0 or len(ref_onsets) == 0:
            return 60  # Default when no onsets detected

        # For each reference onset, find the closest user onset
        timing_errors = []
        for ref_time in ref_onsets:
            if len(user_onsets) == 0:
                break
            closest_idx = np.argmin(np.abs(user_onsets - ref_time))
            error = abs(user_onsets[closest_idx] - ref_time)
            timing_errors.append(error)

        if not timing_errors:
            return 60

        mean_error = np.mean(timing_errors)

        # Score based on mean timing error
        # <50ms = excellent, <150ms = good, <300ms = fair, >500ms = poor
        if mean_error < 0.05:
            score = 95
        elif mean_error < 0.10:
            score = 88
        elif mean_error < 0.15:
            score = 80
        elif mean_error < 0.25:
            score = 70
        elif mean_error < 0.40:
            score = 55
        else:
            score = max(20, int(40 - mean_error * 50))

        return int(np.clip(score, 0, 100))

    except Exception as e:
        logger.warning(f"Timing scoring error: {e}")
        return 60


def score_tempo(y_user: np.ndarray, y_ref: np.ndarray, sr: int) -> int:
    """
    Score tempo consistency by comparing beat patterns.

    Extracts BPM from both tracks and measures:
    - How close the user's tempo is to the reference
    - How consistent the user's tempo stays throughout

    Returns: score 0-100
    """
    import librosa

    try:
        # Extract tempo
        user_tempo, user_beats = librosa.beat.beat_track(y=y_user, sr=sr)
        ref_tempo, ref_beats = librosa.beat.beat_track(y=y_ref, sr=sr)

        # Handle numpy array returns (librosa may return array)
        if hasattr(user_tempo, '__len__'):
            user_tempo = float(user_tempo[0]) if len(user_tempo) > 0 else 120.0
        if hasattr(ref_tempo, '__len__'):
            ref_tempo = float(ref_tempo[0]) if len(ref_tempo) > 0 else 120.0

        if ref_tempo == 0:
            return 70

        # Calculate tempo ratio (how close user's BPM is to reference)
        tempo_ratio = user_tempo / ref_tempo
        tempo_deviation = abs(1.0 - tempo_ratio)

        # Score based on deviation
        if tempo_deviation < 0.03:
            base_score = 95
        elif tempo_deviation < 0.07:
            base_score = 85
        elif tempo_deviation < 0.12:
            base_score = 75
        elif tempo_deviation < 0.20:
            base_score = 60
        else:
            base_score = max(20, int(50 - tempo_deviation * 100))

        # Bonus/penalty for beat consistency within user's track
        if len(user_beats) >= 4:
            beat_times = librosa.frames_to_time(user_beats, sr=sr)
            intervals = np.diff(beat_times)
            if len(intervals) > 0:
                consistency = 1.0 - (np.std(intervals) / np.mean(intervals))
                consistency_bonus = max(-10, min(5, int(consistency * 10)))
                base_score += consistency_bonus

        return int(np.clip(base_score, 0, 100))

    except Exception as e:
        logger.warning(f"Tempo scoring error: {e}")
        return 65


def score_volume(y_user: np.ndarray, y_ref: np.ndarray, sr: int) -> int:
    """
    Score volume/dynamics control by comparing RMS energy envelopes.

    Measures how well the user matches the reference's volume dynamics
    (louder in chorus, softer in verses, etc.)

    Returns: score 0-100
    """
    import librosa

    config = _get_ml_config()

    try:
        # Extract RMS energy
        user_rms = librosa.feature.rms(
            y=y_user, hop_length=config['HOP_LENGTH']
        )[0]
        ref_rms = librosa.feature.rms(
            y=y_ref, hop_length=config['HOP_LENGTH']
        )[0]

        if len(user_rms) == 0 or len(ref_rms) == 0:
            return 65

        # Normalize both to [0, 1]
        user_norm = user_rms / (np.max(user_rms) + 1e-10)
        ref_norm = ref_rms / (np.max(ref_rms) + 1e-10)

        # Resample to same length for comparison
        min_len = min(len(user_norm), len(ref_norm))
        if min_len == 0:
            return 65

        # Simple resampling via interpolation
        user_resampled = np.interp(
            np.linspace(0, 1, min_len),
            np.linspace(0, 1, len(user_norm)),
            user_norm,
        )
        ref_resampled = np.interp(
            np.linspace(0, 1, min_len),
            np.linspace(0, 1, len(ref_norm)),
            ref_norm,
        )

        # Compute correlation between volume envelopes
        correlation = np.corrcoef(user_resampled, ref_resampled)[0, 1]

        # Handle NaN correlation
        if np.isnan(correlation):
            correlation = 0.0

        # Also compute mean absolute difference
        mean_diff = np.mean(np.abs(user_resampled - ref_resampled))

        # Combined score: weighted correlation + dynamics matching
        corr_score = max(0, (correlation + 1) / 2) * 100  # Map [-1,1] to [0,100]
        diff_score = max(0, 100 - mean_diff * 200)  # Penalize large differences

        score = int(corr_score * 0.6 + diff_score * 0.4)
        return int(np.clip(score, 0, 100))

    except Exception as e:
        logger.warning(f"Volume scoring error: {e}")
        return 65


# ═══════════════════════════════════════════════
# 4. Feedback Generator
# ═══════════════════════════════════════════════

def generate_feedback(pitch: int, timing: int, tempo: int, volume: int) -> str:
    """
    Generate constructive textual feedback based on numeric scores.

    Translates per-category scores into actionable coaching advice.
    Uses rule-based NLP (no model needed).

    Returns: Multi-sentence feedback string.
    """
    overall = calculate_overall(pitch, timing, tempo, volume)
    parts = []

    # Overall impression
    if overall >= 90:
        parts.append("Outstanding performance! Your vocal control is exceptional.")
    elif overall >= 80:
        parts.append("Great singing! You showed strong vocal skills throughout the song.")
    elif overall >= 70:
        parts.append("Good effort! You have a solid foundation with room for growth.")
    elif overall >= 60:
        parts.append("Nice attempt! With some focused practice, you can improve significantly.")
    else:
        parts.append("Keep practicing! Every great singer started with consistent effort.")

    # Pitch feedback
    if pitch >= 90:
        parts.append("Your pitch accuracy is remarkable — you hit the notes with precision.")
    elif pitch >= 75:
        parts.append("Your pitch is generally accurate, with occasional drifting on sustained notes.")
    elif pitch >= 60:
        parts.append("Watch your pitch on the higher notes — try warming up with scales before singing.")
    else:
        parts.append("Focus on pitch control by practicing along with the melody slowly before full speed.")

    # Timing feedback
    if timing >= 90:
        parts.append("Your timing is spot-on with the beat.")
    elif timing >= 75:
        parts.append("Your rhythm is mostly on time, with slight delays on some note entries.")
    elif timing >= 60:
        parts.append("Try to anticipate the beat slightly — you tend to come in a bit late on verses.")
    else:
        parts.append("Timing needs work. Practice clapping along with the rhythm before adding vocals.")

    # Tempo feedback
    if tempo >= 90:
        parts.append("You maintained a consistent tempo throughout.")
    elif tempo >= 75:
        parts.append("Your pace was mostly steady, with slight speeding up during faster sections.")
    elif tempo >= 60:
        parts.append("You tend to rush through certain parts. Try using a metronome during practice.")
    else:
        parts.append("Speed consistency is a challenge — practice with a metronome to build tempo awareness.")

    # Volume feedback
    if volume >= 90:
        parts.append("Excellent dynamics control — your volume changes matched the song beautifully.")
    elif volume >= 75:
        parts.append("Good volume control overall, with some inconsistencies in softer passages.")
    elif volume >= 60:
        parts.append("Try to match the song's dynamics more closely — softer in verses, stronger in choruses.")
    else:
        parts.append("Work on breath control to maintain consistent volume throughout the performance.")

    return " ".join(parts)


def calculate_overall(pitch: int, timing: int, tempo: int, volume: int) -> int:
    """
    Calculate weighted overall score from category scores.

    Weights:
        Pitch:  40% — Most important for karaoke
        Timing: 25% — Critical for sync with music
        Tempo:  20% — Speed consistency
        Volume: 15% — Dynamics control
    """
    weighted = (
        pitch * 0.40 +
        timing * 0.25 +
        tempo * 0.20 +
        volume * 0.15
    )
    return int(np.clip(round(weighted), 0, 100))


# ═══════════════════════════════════════════════
# 5. Main Scoring Pipeline
# ═══════════════════════════════════════════════

def score_recording(user_audio_path: str, ref_audio_path: str) -> dict:
    """
    Run the full vocal scoring pipeline on a user recording.

    This is the main entry point called by the API view.

    Args:
        user_audio_path: Path to the user's vocal recording
        ref_audio_path: Path to the reference vocal track

    Returns:
        Dict with keys: overall, pitch_score, timing_score,
        tempo_score, volume_score, feedback
    """
    config = _get_ml_config()
    sr = config['SAMPLE_RATE']

    logger.info(f"Starting vocal scoring: user={user_audio_path}, ref={ref_audio_path}")

    # Load audio files
    y_user, sr = load_audio(user_audio_path, sr=sr)
    y_ref, sr = load_audio(ref_audio_path, sr=sr)

    logger.info(f"Audio loaded: user={len(y_user)} samples, ref={len(y_ref)} samples")

    # Extract pitch
    f0_user = extract_pitch(y_user, sr)
    f0_ref = extract_pitch(y_ref, sr)

    # Convert to MIDI and clean
    midi_user = clean_pitch(f0_to_midi(f0_user))
    midi_ref = clean_pitch(f0_to_midi(f0_ref))

    logger.info(f"Pitch extracted: user={len(midi_user)} frames, ref={len(midi_ref)} frames")

    # Calculate all scores
    pitch = score_pitch(midi_user, midi_ref)
    timing = score_timing(y_user, y_ref, sr)
    tempo = score_tempo(y_user, y_ref, sr)
    volume = score_volume(y_user, y_ref, sr)
    overall = calculate_overall(pitch, timing, tempo, volume)
    feedback = generate_feedback(pitch, timing, tempo, volume)

    result = {
        'overall': overall,
        'pitch_score': pitch,
        'timing_score': timing,
        'tempo_score': tempo,
        'volume_score': volume,
        'feedback': feedback,
    }

    logger.info(f"Scoring complete: {result}")
    return result
