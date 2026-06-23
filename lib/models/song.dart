import 'package:flutter/material.dart';

/// Song data model — matches the data shape used in Home.tsx, Library.tsx, etc.
class Song {
  final int id;
  final String title;
  final String artist;
  final List<Color> gradientColors;
  final String? imageUrl;
  final String? audioUrl;
  final List<dynamic>? lyrics;
  final String? plays;
  final int duration; // seconds

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.gradientColors,
    this.imageUrl,
    this.audioUrl,
    this.lyrics,
    this.plays,
    this.duration = 234,
  });

  /// Format duration as m:ss
  String get formattedDuration {
    final mins = duration ~/ 60;
    final secs = duration % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  // ─── Mock Data (matching Home.tsx) ──────────────────────────

  static const List<Song> recentlyPlayed = [
    Song(
      id: 1,
      title: 'Midnight Dreams',
      artist: 'Aurora Bay',
      gradientColors: [Color(0xFFFA233B), Color(0xFFC41E30)],
      duration: 234,
    ),
    Song(
      id: 2,
      title: 'Electric Soul',
      artist: 'The Neon Waves',
      gradientColors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
      duration: 252,
    ),
    Song(
      id: 3,
      title: 'Cosmic Love',
      artist: 'Stella Nova',
      gradientColors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      duration: 208,
    ),
    Song(
      id: 4,
      title: 'Urban Lights',
      artist: 'City Pulse',
      gradientColors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
      duration: 225,
    ),
  ];

  static const List<Song> trending = [
    Song(
      id: 5,
      title: 'Summer Nights',
      artist: 'Ocean Drive',
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      plays: '2.4M',
      duration: 242,
    ),
    Song(
      id: 6,
      title: 'Neon Paradise',
      artist: 'Synthwave City',
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      plays: '1.8M',
      duration: 198,
    ),
    Song(
      id: 7,
      title: 'Velvet Sky',
      artist: 'Luna Echo',
      gradientColors: [Color(0xFFF97316), Color(0xFFEA580C)],
      plays: '1.5M',
      duration: 267,
    ),
  ];
}
