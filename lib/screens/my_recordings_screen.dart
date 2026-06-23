import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/recording.dart';
import '../widgets/recording_list_tile.dart';

/// My Recordings screen — redesigned to match the new card layout with
/// metric badges (Pitch, Timing, Tone). Tapping a card navigates to
/// the performance report for that recording.
class MyRecordingsScreen extends StatelessWidget {
  const MyRecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recordings = Recording.mockRecordings;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
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
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Recordings',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recordings.length} recordings',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Recording cards list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: recordings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final r = recordings[i];
                  return RecordingListTile(
                    songTitle: r.songTitle,
                    artist: r.artist,
                    date: r.date,
                    duration: r.duration,
                    score: r.score,
                    pitchPercent: r.pitchPercent,
                    timingPercent: r.timingPercent,
                    tonePercent: r.tonePercent,
                    gradientColors: r.gradientColors,
                    onTap: () => context.push(
                      '/performance-report',
                      extra: r,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
