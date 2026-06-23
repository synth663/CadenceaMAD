import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Real-time vocal scoring state — matches NowPlaying.tsx scoring logic.
/// Updates every 800ms with simulated random variations.
class ScoringProvider extends ChangeNotifier {
  int _pitchAccuracy = 88;
  int _pitchDeviation = 0; // -50 to +50 (cents)
  int _timingAccuracy = 92;
  int _timingOffset = 0; // -100 to +100 ms (negative = early, positive = late)
  int _tempoAlignment = 87;
  int _volumeConsistency = 85;
  int _overallScore = 88;

  Timer? _scoringTimer;
  final Random _random = Random();

  int get pitchAccuracy => _pitchAccuracy;
  int get pitchDeviation => _pitchDeviation;
  int get timingAccuracy => _timingAccuracy;
  int get timingOffset => _timingOffset;
  int get tempoAlignment => _tempoAlignment;
  int get volumeConsistency => _volumeConsistency;
  int get overallScore => _overallScore;

  /// Timing offset display text (matches NowPlaying.tsx logic).
  String get timingOffsetText {
    if (_timingOffset < 0) {
      return '${_timingOffset.abs()}ms early';
    } else if (_timingOffset > 0) {
      return '${_timingOffset}ms late';
    }
    return 'Perfect';
  }

  /// Start real-time scoring simulation (called when playback starts).
  void startScoring() {
    stopScoring();
    _scoringTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      // Random variations matching NowPlaying.tsx useEffect
      _pitchAccuracy = 85 + _random.nextInt(12);
      _pitchDeviation = _random.nextInt(40) - 20;
      _timingAccuracy = 88 + _random.nextInt(10);
      _timingOffset = _random.nextInt(80) - 40;
      _tempoAlignment = 83 + _random.nextInt(12);
      _volumeConsistency = 82 + _random.nextInt(14);

      // Calculate overall score (average of 4 metrics)
      _overallScore = (_pitchAccuracy + _timingAccuracy + _tempoAlignment + _volumeConsistency) ~/ 4;

      notifyListeners();
    });
  }

  /// Stop scoring simulation (called when playback pauses/stops).
  void stopScoring() {
    _scoringTimer?.cancel();
    _scoringTimer = null;
  }

  /// Reset all scores to defaults.
  void reset() {
    _pitchAccuracy = 88;
    _pitchDeviation = 0;
    _timingAccuracy = 92;
    _timingOffset = 0;
    _tempoAlignment = 87;
    _volumeConsistency = 85;
    _overallScore = 88;
    notifyListeners();
  }

  @override
  void dispose() {
    stopScoring();
    super.dispose();
  }
}
