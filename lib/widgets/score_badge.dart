import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Color-coded score badge pill.
/// Matches the score display logic in MyRecordings.tsx and Profile.tsx.
class ScoreBadge extends StatelessWidget {
  final int score;
  final double fontSize;

  const ScoreBadge({
    super.key,
    required this.score,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (score >= 90) {
      bgColor = const Color(0xFF4ADE80).withValues(alpha: 0.2);
      borderColor = const Color(0xFF4ADE80).withValues(alpha: 0.3);
      textColor = const Color(0xFF4ADE80);
    } else if (score >= 80) {
      bgColor = const Color(0xFFFACC15).withValues(alpha: 0.2);
      borderColor = const Color(0xFFFACC15).withValues(alpha: 0.3);
      textColor = const Color(0xFFFACC15);
    } else {
      bgColor = AppColors.textMuted.withValues(alpha: 0.2);
      borderColor = AppColors.textMuted.withValues(alpha: 0.3);
      textColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Text(
        '$score',
        style: AppTextStyles.bodySM.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
