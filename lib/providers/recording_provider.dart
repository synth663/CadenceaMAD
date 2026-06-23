import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Recording state management using the 'record' package.
class RecordingProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _hasRecording = false;
  double _micLevel = 0.0; // 0.0 to 1.0
  double _vocalVolume = 0.75;
  double _instrumentalVolume = 0.60;
  
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  String? _recordedFilePath;

  bool get isRecording => _isRecording;
  bool get hasRecording => _hasRecording;
  double get micLevel => _micLevel;
  double get vocalVolume => _vocalVolume;
  double get instrumentalVolume => _instrumentalVolume;
  String? get recordedFilePath => _recordedFilePath;

  /// Start recording. Requests permissions if needed.
  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Microphone permission denied.');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _recordedFilePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordedFilePath!,
      );

      _isRecording = true;
      _hasRecording = false;
      notifyListeners();

      _startMicSimulation();
    } catch (e) {
      debugPrint('Failed to start recording: $e');
    }
  }

  /// Stop recording.
  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _hasRecording = true;
      _recordedFilePath = path;
      
      _stopMicSimulation();
      _micLevel = 0.0;
      notifyListeners();
      
      debugPrint('Recording saved to: $_recordedFilePath');
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
    }
  }

  /// Set vocal volume (0.0 to 1.0).
  void setVocalVolume(double value) {
    _vocalVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Set instrumental volume (0.0 to 1.0).
  void setInstrumentalVolume(double value) {
    _instrumentalVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Reset recording state.
  void reset() {
    if (_isRecording) {
      stopRecording();
    }
    _isRecording = false;
    _hasRecording = false;
    _micLevel = 0.0;
    _vocalVolume = 0.75;
    _instrumentalVolume = 0.60;
    _recordedFilePath = null;
    notifyListeners();
  }

  void _startMicSimulation() {
    _stopMicSimulation();
    _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
      // amplitude.current ranges from roughly -160 to 0. 
      // We normalize it to a 0.0 - 1.0 scale.
      final normalized = (amp.current + 60) / 60; // Assumes -60 is silent, 0 is max.
      _micLevel = normalized.clamp(0.0, 1.0);
      notifyListeners();
    });
  }

  void _stopMicSimulation() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
  }

  @override
  void dispose() {
    _stopMicSimulation();
    _audioRecorder.dispose();
    super.dispose();
  }
}
