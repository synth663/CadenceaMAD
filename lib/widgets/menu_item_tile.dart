import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Profile settings menu row with icon, label, optional badge, and chevron.
/// Matches the menu items in Profile.tsx.
class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const MenuItemTile({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                size: 18.0,
                color: iconColor ?? AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 16.0),
            // Label
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySM.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            // Badge
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
            ],
            // Chevron
            Icon(
              LucideIcons.chevronRight,
              size: 18.0,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
