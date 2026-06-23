import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Achievement badge grid item with locked/unlocked states.
/// Matches the achievements section in Profile.tsx.
class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isUnlocked;
  final Color accentColor;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isUnlocked = false,
    this.accentColor = AppColors.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: isUnlocked
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              )
            : BoxDecoration(
                color: AppColors.backgroundCard.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1.0,
                ),
              ),
        child: Column(
          children: [
            // Icon circle
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? accentColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(
                icon,
                size: 20.0,
                color: isUnlocked ? accentColor : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8.0),
            // Title
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2.0),
            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(fontSize: 10.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
