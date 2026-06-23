import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

/// Feature card for the Welcome screen.
/// Matches the feature list items in Welcome.tsx.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  final Color borderColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDecorations.cardPadding),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDecorations.radiusCard),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, size: AppDecorations.iconLG, color: AppColors.textWhite),
          ),
          const SizedBox(width: AppColors.gapLG),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textSecondary,
                    height: AppTextStyles.lineHeightRelaxed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
