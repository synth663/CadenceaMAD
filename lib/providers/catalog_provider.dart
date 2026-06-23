import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class CatalogProvider extends ChangeNotifier {
  List<Song> _songs = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  Future<void> fetchSongs() async {
    if (_hasFetched || _isLoading) return;

    _isLoading = true;
    // Notify listeners so UI shows loading state
    notifyListeners();

    try {
      // Use 127.0.0.1 for all platforms so physical devices can connect via adb reverse tcp:8000 tcp:8000
      final host = '127.0.0.1';
      final url = Uri.parse('http://$host:8000/api/songs/');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> data = decoded is Map<String, dynamic> && decoded.containsKey('results')
            ? decoded['results']
            : decoded;

        _songs = data.map((json) {
          String formattedPlays = '0';
          final playsInt = json['plays'] ?? 0;
          if (playsInt >= 1000000) {
            formattedPlays = '${(playsInt / 1000000).toStringAsFixed(1)}M';
          } else if (playsInt >= 1000) {
            formattedPlays = '${(playsInt / 1000).toStringAsFixed(1)}K';
          } else {
            formattedPlays = playsInt.toString();
          }

          final artistData = json['artist'];
          final artistName = artistData is Map ? artistData['name'] : (artistData ?? 'Unknown Artist');

          return Song(
            id: json['id'],
            title: json['title'] ?? 'Unknown',
            artist: artistName,
            gradientColors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
            imageUrl: json['cover_url'],
            audioUrl: json['audio_url'],
            lyrics: json['lyrics'],
            plays: formattedPlays,
            duration: json['duration'] ?? 234,
          );
        }).toList();
      } else {
        _useMockData();
      }
    } catch (e) {
      _useMockData();
    } finally {
      _isLoading = false;
      _hasFetched = true;
      notifyListeners();
    }
  }

  void _useMockData() {
    _songs = [
      ...Song.recentlyPlayed,
      ...Song.trending,
    ];
  }
}
