import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_text_styles.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 72.0,
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2621),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: song.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        const SizedBox(height: 2.0),
                        Text(
                          song.artist,
                          style: AppTextStyles.caption.copyWith(color: Colors.white54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          player.toggleLike();
                        },
                        child: Icon(
                          LucideIcons.heart,
                          size: 20.0,
                          color: player.isLiked ? Colors.redAccent : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      GestureDetector(
                        onTap: () {
                          player.togglePlayPause();
                        },
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE88219),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            player.isPlaying ? LucideIcons.pause : LucideIcons.play,
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      GestureDetector(
                        onTap: () {
                          player.skipForward();
                        },
                        child: const Icon(
                          LucideIcons.skipForward,
                          size: 20.0,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
