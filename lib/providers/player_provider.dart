import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

/// Player state management using just_audio for real playback.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Song? _currentSong;
  bool _isPlaying = false;
  int _currentTime = 0; // seconds
  bool _isLiked = false;
  
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  PlayerProvider() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _currentTime = position.inSeconds;
      notifyListeners();
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero);
      }
      notifyListeners();
    });
  }

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  int get currentTime => _currentTime;
  bool get isLiked => _isLiked;
  
  int get totalDuration => _currentSong?.duration ?? 234;
  
  double get progress => totalDuration > 0 ? _currentTime / totalDuration : 0;

  /// Format time as m:ss
  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String get currentTimeFormatted => formatTime(_currentTime);
  String get totalDurationFormatted => formatTime(totalDuration);

  /// Play a song — sets it as current, loads URL, and starts playback.
  Future<void> playSong(Song song) async {
    _currentSong = song;
    _currentTime = 0;
    _isLiked = false;
    notifyListeners();

    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(song.audioUrl!);
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    } else {
      debugPrint('No audio URL found for song: ${song.title}');
    }
  }

  /// Toggle play/pause.
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  /// Toggle like state.
  void toggleLike() {
    _isLiked = !_isLiked;
    notifyListeners();
  }

  /// Seek to a specific time.
  Future<void> seekTo(int seconds) async {
    await _audioPlayer.seek(Duration(seconds: seconds));
  }

  /// Skip forward
  void skipForward() {
    // For demo, just restart with the same song or seek forward 10s
    seekTo(_currentTime + 10);
  }

  /// Skip backward.
  void skipBack() {
    seekTo(_currentTime > 10 ? _currentTime - 10 : 0);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
