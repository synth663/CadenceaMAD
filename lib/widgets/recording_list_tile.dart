import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Recording card with album art, song info, overall score, and metric badges.
/// Redesigned to match the new My Recordings design with Pitch/Timing/Tone chips.
class RecordingListTile extends StatelessWidget {
  final String songTitle;
  final String artist;
  final String date;
  final String duration;
  final int score;
  final int pitchPercent;
  final int timingPercent;
  final int tonePercent;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const RecordingListTile({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.date,
    required this.duration,
    required this.score,
    required this.pitchPercent,
    required this.timingPercent,
    required this.tonePercent,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Album art + Song info + Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Album art thumbnail
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songTitle,
                        style: AppTextStyles.bodySM.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$artist   $duration   $date',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white54,
                          fontSize: 12.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                // Overall score
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(score),
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Metric badges row
            Row(
              children: [
                _MetricBadge(
                  label: 'Pitch',
                  value: pitchPercent,
                  color: const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 10.0),
                _MetricBadge(
                  label: 'Timing',
                  value: timingPercent,
                  color: const Color(0xFF60A5FA),
                ),
                const SizedBox(width: 10.0),
                _MetricBadge(
                  label: 'Tone',
                  value: tonePercent,
                  color: const Color(0xFFA78BFA),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF4ADE80);
    if (score >= 80) return const Color(0xFF60A5FA);
    if (score >= 70) return const Color(0xFFFBBF24);
    return AppColors.textMuted;
  }
}

/// Individual metric badge chip (e.g. "92% Pitch")
class _MetricBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.6),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
