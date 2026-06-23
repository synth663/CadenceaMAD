import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/catalog_provider.dart';

class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: Consumer<CatalogProvider>(
          builder: (context, catalog, child) {
            final recentlyPlayed = catalog.songs.take(15).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Recently Played',
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Song List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: recentlyPlayed.length,
                    itemBuilder: (context, index) {
                      final song = recentlyPlayed[index];
                      return _buildSongCard(context, song);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSongCard(BuildContext context, Song song) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2E2621),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Album Art
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: const Color(0xFF1A0F0B),
                image: song.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(song.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: song.imageUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          colors: song.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(LucideIcons.music, color: Colors.white54, size: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 16.0),
            // Title & Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodySM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption.copyWith(color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // Play Button
            GestureDetector(
              onTap: () {
                context.read<PlayerProvider>().playSong(song);
                context.push('/now-playing');
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE88219),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE88219).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8.0),
            // More Menu
            Theme(
              data: Theme.of(context).copyWith(
                cardColor: const Color(0xFF2E2621),
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle actions
                },
                icon: const Icon(LucideIcons.moreVertical, size: 20, color: Colors.white54),
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.heart, size: 18, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Add to liked songs', style: AppTextStyles.bodySM.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'download',
                    enabled: false, // Grayed out
                    child: Row(
                      children: [
                        Icon(LucideIcons.download, size: 18, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(width: 12),
                        Text('Download recording', style: AppTextStyles.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'play',
                    enabled: false, // Grayed out
                    child: Row(
                      children: [
                        Icon(LucideIcons.playCircle, size: 18, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(width: 12),
                        Text('Play recording', style: AppTextStyles.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'analysis',
                    enabled: false, // Grayed out
                    child: Row(
                      children: [
                        Icon(LucideIcons.barChart2, size: 18, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(width: 12),
                        Text('Performance analysis', style: AppTextStyles.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
