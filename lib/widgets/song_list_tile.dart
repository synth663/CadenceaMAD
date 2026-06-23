import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

/// Numbered trending song row with plays count.
/// Matches the "Trending Now" list items in Home.tsx.
class SongListTile extends StatelessWidget {
  final int index;
  final String title;
  final String artist;
  final String? plays;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const SongListTile({
    super.key,
    required this.index,
    required this.title,
    required this.artist,
    this.plays,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppColors.paddingMD),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Index number
            SizedBox(
              width: 24.0,
              child: Text(
                '${index + 1}',
                style: AppTextStyles.bodySM.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppColors.gapLG),
            // Album art
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [AppDecorations.shadowLG],
              ),
            ),
            const SizedBox(width: AppColors.gapLG),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    artist,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Plays count
            if (plays != null)
              Text(
                '$plays plays',
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }
}
