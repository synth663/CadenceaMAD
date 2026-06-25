import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_text_styles.dart';
import '../models/song.dart';

/// Modal bottom sheet that displays and manages the current playback queue.
/// Songs can be reordered via long-press drag, and tapping jumps to that song.
class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QueueBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final queue = player.queue;
        final currentIndex = player.queueIndex;

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1510),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Queue',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${queue.length} songs',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Queue list
              Expanded(
                child: queue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: queue.length,
                        onReorder: (oldIndex, newIndex) {
                          player.reorderQueue(oldIndex, newIndex);
                        },
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            color: Colors.transparent,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E2621).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: child,
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          final song = queue[index];
                          final isCurrent = index == currentIndex;

                          return _QueueItem(
                            key: ValueKey('queue_${song.id}_$index'),
                            song: song,
                            isCurrent: isCurrent,
                            index: index,
                            onTap: () {
                              player.playFromQueue(index);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QueueItem extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final int index;
  final VoidCallback onTap;

  const _QueueItem({
    super.key,
    required this.song,
    required this.isCurrent,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFFE88219).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent
              ? Border.all(color: const Color(0xFFE88219).withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            // Album art
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2E2621),
              ),
              child: song.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          LucideIcons.music,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : Icon(
                      LucideIcons.music,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodySM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? const Color(0xFFE88219) : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Now playing indicator or drag handle
            if (isCurrent)
              Icon(
                LucideIcons.volume2,
                size: 16,
                color: const Color(0xFFE88219),
              )
            else
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    LucideIcons.gripVertical,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
