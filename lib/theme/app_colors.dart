import 'package:flutter/material.dart';

/// Cadencea Color Palette — from DESIGN_TOKENS.md
/// All color constants organized by category.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───────────────────────────────────────────
  /// Primary Brand Color (Apple Music Red)
  static const Color primaryRed = Color(0xFFFA233B);
  static const Color primaryRedDark = Color(0xFFC41E30);
  static const Color primaryRedHover = Color(0xFFE01F35);
  static const Color primaryRedLight = Color(0xFFB01A2A);

  /// Destructive/Error
  static const Color destructive = Color(0xFFD4183D);

  // ─── Background Colors (Near-Black) ─────────────────────────
  static const Color backgroundPrimary = Color(0xFF0A0A0A);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);
  static const Color backgroundCard = Color(0xFF141414);

  // ─── Surface Colors ─────────────────────────────────────────
  static const Color surfacePrimary = Color(0xFF1F1F1F);
  static const Color surfaceMuted = Color(0xFF2A2A2A);
  static const Color surfacePopover = Color(0xFF1A1A1A);

  // ─── Text Colors ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFFA0A0A0);
  static const Color textDisabled = Color(0xFF606060);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ─── Accent & Semantic Colors ───────────────────────────────
  /// Success (Green)
  static const Color accentGreen = Color(0xFF4ADE80);

  /// Info (Blue)
  static const Color accentBlue = Color(0xFF60A5FA);

  /// Warning/Achievement (Purple)
  static const Color accentPurple = Color(0xFFA78BFA);

  // ─── Chart Colors ───────────────────────────────────────────
  static const Color chart1 = Color(0xFFFA233B);
  static const Color chart2 = Color(0xFFFF4757);
  static const Color chart3 = Color(0xFFFF6B7A);
  static const Color chart4 = Color(0xFF828282);
  static const Color chart5 = Color(0xFFA0A0A0);

  // ─── Opacity Values ─────────────────────────────────────────
  /// White Overlays (for glassmorphism)
  static const double opacity5 = 0.05;
  static const double opacity10 = 0.10;
  static const double opacity15 = 0.15;
  static const double opacity20 = 0.20;
  static const double opacity30 = 0.30;

  /// Black Overlays
  static const double opacityBlack20 = 0.20;
  static const double opacityBlack30 = 0.30;

  /// Element Opacity
  static const double opacityDisabled = 0.50;
  static const double opacityHover = 0.70;
  static const double opacityFull = 1.00;

  // ─── Border Colors ──────────────────────────────────────────
  static final Color borderDefault = Colors.white.withValues(alpha: 0.1);
  static final Color borderInput = Colors.white.withValues(alpha: 0.1);
  static final Color borderRed = const Color(0xFFFA233B).withValues(alpha: 0.5);
  static final Color borderError = const Color(0xFFD4183D).withValues(alpha: 0.5);

  // ─── Focus/Ring Colors ──────────────────────────────────────
  static final Color ringDefault = const Color(0xFFFA233B).withValues(alpha: 0.3);
  static final Color ringDestructive = const Color(0xFFD4183D).withValues(alpha: 0.2);
  static final Color ringDestructiveDark = const Color(0xFFD4183D).withValues(alpha: 0.4);

  // ─── Score Colors (based on percentage) ─────────────────────
  static const Color scoreExcellent = Color(0xFF4ADE80); // 90-100%
  static const Color scoreGood = Color(0xFF60A5FA);      // 75-89%
  static const Color scoreAverage = Color(0xFFFBBF24);   // 60-74%
  static const Color scorePoor = Color(0xFFFA233B);      // < 60%

  /// Returns the appropriate score color for a given percentage.
  static Color scoreColor(double percentage) {
    if (percentage >= 90) return scoreExcellent;
    if (percentage >= 75) return scoreGood;
    if (percentage >= 60) return scoreAverage;
    return scorePoor;
  }

  // ─── Spacing System (8pt Grid) ──────────────────────────────
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;
  static const double space24 = 96.0;

  // ─── Component Spacing ──────────────────────────────────────
  /// Padding
  static const double paddingXS = 8.0;
  static const double paddingSM = 12.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 20.0;
  static const double paddingXL = 24.0;

  /// Gaps (between flex items)
  static const double gapXS = 4.0;
  static const double gapSM = 8.0;
  static const double gapMD = 12.0;
  static const double gapLG = 16.0;
  static const double gapXL = 24.0;

  // ─── Screen Padding ─────────────────────────────────────────
  static const double screenPaddingHorizontal = 24.0;
  static const double screenPaddingTop = 48.0;
  static const double screenPaddingBottom = 48.0;
}
