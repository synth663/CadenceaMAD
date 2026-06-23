import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Progress bar with label and percentage.
/// Matches the scoring metric bars in NowPlaying.tsx and PerformanceReport.tsx.
class MetricBar extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int percentage;
  final Color color;
  final String? subtitle;

  const MetricBar({
    super.key,
    required this.label,
    this.icon,
    required this.percentage,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13.0, color: color),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const Spacer(),
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(fontSize: 10.0),
              ),
              const SizedBox(width: 8.0),
            ],
            Text(
              '$percentage%',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        // Progress bar
        Container(
          height: 6.0,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: constraints.maxWidth * (percentage / 100).clamp(0.0, 1.0),
                    height: 6.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.5), color],
                      ),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
