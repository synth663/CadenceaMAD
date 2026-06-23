import 'package:flutter/material.dart';

/// Recording data model — matches the data shape in MyRecordings.tsx
class Recording {
  final int id;
  final String songTitle;
  final String artist;
  final String date;
  final String duration;
  final int score;
  final int pitchPercent;
  final int timingPercent;
  final int tonePercent;
  final List<Color> gradientColors;

  const Recording({
    required this.id,
    required this.songTitle,
    required this.artist,
    required this.date,
    required this.duration,
    required this.score,
    required this.pitchPercent,
    required this.timingPercent,
    required this.tonePercent,
    required this.gradientColors,
  });

  // ─── Mock Data ───────────────────────────────────────────────

  static const List<Recording> mockRecordings = [
    Recording(
      id: 1,
      songTitle: 'Midnight Dreams',
      artist: 'Aurora Bay',
      date: 'Mar 24, 2026',
      duration: '3:54',
      score: 87,
      pitchPercent: 92,
      timingPercent: 85,
      tonePercent: 84,
      gradientColors: [Color(0xFFFA233B), Color(0xFFC41E30)],
    ),
    Recording(
      id: 2,
      songTitle: 'Electric Soul',
      artist: 'The Neon Waves',
      date: 'Mar 23, 2026',
      duration: '4:12',
      score: 92,
      pitchPercent: 95,
      timingPercent: 90,
      tonePercent: 88,
      gradientColors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    ),
    Recording(
      id: 3,
      songTitle: 'Cosmic Love',
      artist: 'Stella Nova',
      date: 'Mar 22, 2026',
      duration: '3:28',
      score: 78,
      pitchPercent: 80,
      timingPercent: 76,
      tonePercent: 74,
      gradientColors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    ),
    Recording(
      id: 4,
      songTitle: 'Urban Lights',
      artist: 'City Pulse',
      date: 'Mar 20, 2026',
      duration: '3:45',
      score: 85,
      pitchPercent: 88,
      timingPercent: 82,
      tonePercent: 80,
      gradientColors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    ),
    Recording(
      id: 5,
      songTitle: 'Summer Nights',
      artist: 'Ocean Drive',
      date: 'Mar 19, 2026',
      duration: '4:02',
      score: 90,
      pitchPercent: 93,
      timingPercent: 88,
      tonePercent: 86,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    ),
  ];
}
