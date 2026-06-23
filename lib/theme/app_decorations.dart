import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Cadencea Decorations — from DESIGN_TOKENS.md
/// BoxDecorations, shadows, gradients, radii, and animation constants.
class AppDecorations {
  AppDecorations._();

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════

  static const double radiusXS = 8.0;
  static const double radiusSM = 16.0;
  static const double radiusMD = 18.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radius2XL = 32.0;
  static const double radius3XL = 48.0;

  /// Common Usage
  static const double radiusCard = 20.0;
  static const double radiusButton = 32.0;
  static const double radiusInput = 24.0;
  static const double radiusDialog = 20.0;
  static const double radiusFull = 9999.0;

  // ═══════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════

  /// Small Shadow (subtle elevation)
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0D000000),
    offset: Offset(0, 1),
    blurRadius: 2.0,
    spreadRadius: 0,
  );

  /// Medium Shadow (default elevation)
  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 6.0,
    spreadRadius: -1,
  );

  /// Large Shadow (prominent elevation)
  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 10),
    blurRadius: 15.0,
    spreadRadius: -3,
  );

  /// Extra Large Shadow (maximum elevation)
  static const BoxShadow shadowXL = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 20),
    blurRadius: 25.0,
    spreadRadius: -5,
  );

  /// 2XL Shadow (dramatic depth - used on hero elements)
  static const BoxShadow shadow2XL = BoxShadow(
    color: Color(0x40000000),
    offset: Offset(0, 25),
    blurRadius: 50.0,
    spreadRadius: -12,
  );

  // ─── Glow Effects ───────────────────────────────────────────
  /// Red Glow (primary accent glow)
  static const BoxShadow glowRed = BoxShadow(
    color: Color(0x40FA233B),
    offset: Offset(0, 0),
    blurRadius: 20.0,
    spreadRadius: 0,
  );

  /// Subtle Glow
  static const BoxShadow glowSubtle = BoxShadow(
    color: Color(0x26FA233B),
    offset: Offset(0, 8),
    blurRadius: 24.0,
    spreadRadius: 0,
  );

  // ═══════════════════════════════════════════════════════════════
  // BLUR VALUES (for BackdropFilter)
  // ═══════════════════════════════════════════════════════════════

  static const double blurStrong = 120.0;
  static const double blurMedium = 24.0;
  static const double blurLight = 12.0;

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  /// Primary Gradient (Red) — CTA buttons
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFA233B), Color(0xFFC41E30)],
  );

  /// Primary Gradient Hover
  static const LinearGradient gradientPrimaryHover = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE01F35), Color(0xFFB01A2A)],
  );

  /// Background Gradient (Vertical)
  static const LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A), Color(0xFF0A0A0A)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent Gradients (for feature cards)
  static const LinearGradient gradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x334ADE80), Color(0x0D4ADE80)],
  );

  static const LinearGradient gradientRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FA233B), Color(0x0DFA233B)],
  );

  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x3360A5FA), Color(0x0D60A5FA)],
  );

  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33A78BFA), Color(0x0DA78BFA)],
  );

  // ═══════════════════════════════════════════════════════════════
  // COMPONENT DECORATIONS
  // ═══════════════════════════════════════════════════════════════

  // ─── Buttons ────────────────────────────────────────────────

  static const double buttonHeightPrimary = 56.0;
  static const double buttonPaddingHorizontal = 20.0;

  /// Primary CTA Button
  static BoxDecoration get buttonPrimary => BoxDecoration(
        gradient: gradientPrimary,
        borderRadius: BorderRadius.circular(radiusButton),
        boxShadow: const [shadow2XL],
      );

  /// Primary CTA Button (hover)
  static BoxDecoration get buttonPrimaryHover => BoxDecoration(
        gradient: gradientPrimaryHover,
        borderRadius: BorderRadius.circular(radiusButton),
        boxShadow: const [shadow2XL],
      );

  /// Secondary Button
  static BoxDecoration get buttonSecondary => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusButton),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  static const double iconButtonSize = 36.0;

  /// Icon Button
  static BoxDecoration get iconButton => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18.0),
      );

  // ─── Input Fields ───────────────────────────────────────────

  static const double inputHeight = 56.0;
  static const double inputPaddingLeft = 48.0;
  static const double inputPaddingRight = 48.0;

  /// Input Default State
  static BoxDecoration get inputDefault => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radiusInput),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Input Focused State
  static BoxDecoration get inputFocused => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusInput),
        border: Border.all(
          color: const Color(0xFFFA233B).withValues(alpha: 0.5),
          width: 1.0,
        ),
      );

  /// Input Error State
  static BoxDecoration get inputError => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radiusInput),
        border: Border.all(
          color: const Color(0xFFD4183D).withValues(alpha: 0.5),
          width: 1.0,
        ),
      );

  // ─── Cards ──────────────────────────────────────────────────

  static const double cardPadding = 20.0;

  /// Standard Card
  static BoxDecoration get cardDefault => BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Glassmorphic Card
  static BoxDecoration get cardGlass => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Accent Card (with gradient background)
  static BoxDecoration get cardAccent => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x33FA233B), Color(0x0DFA233B)],
        ),
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: const Color(0xFFFA233B).withValues(alpha: 0.3),
          width: 1.0,
        ),
      );

  // ─── Bottom Navigation Bar ──────────────────────────────────

  static const double navBarHeight = 80.0;
  static const double navBarPaddingBottom = 32.0;
  static const double navBarIconSize = 24.0;
  static const double navBarItemGap = 4.0;

  /// Navigation Bar
  static BoxDecoration get navBar => BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      );

  // ─── Mini Player Bar ────────────────────────────────────────

  static const double miniPlayerHeight = 72.0;
  static const double miniPlayerPadding = 16.0;
  static const double miniPlayerRadius = 16.0;
  static const double miniPlayerAlbumSize = 48.0;
  static const double miniPlayerAlbumRadius = 8.0;

  /// Mini Player
  static BoxDecoration get miniPlayer => BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(miniPlayerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  // ─── Progress Bars ──────────────────────────────────────────

  static const double progressBarHeight = 4.0;
  static const double progressBarRadius = 2.0;
  static const double progressThumbSize = 16.0;

  /// Progress Background Track
  static BoxDecoration get progressBackground => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(progressBarRadius),
      );

  /// Progress Filled Track
  static BoxDecoration get progressFilled => BoxDecoration(
        gradient: gradientPrimary,
        borderRadius: BorderRadius.circular(progressBarRadius),
      );

  /// Progress Thumb
  static BoxDecoration get progressThumb => const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [shadowMD],
      );

  // ─── Achievement Badges ─────────────────────────────────────

  static const double badgeSize = 64.0;
  static const double badgeBorderRadius = 16.0;
  static const double badgeIconSize = 32.0;

  /// Locked Badge
  static BoxDecoration get badgeLocked => BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(badgeBorderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Unlocked Badge (Gold)
  static BoxDecoration get badgeUnlocked => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(badgeBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FBBF24),
            offset: Offset(0, 8),
            blurRadius: 24.0,
          ),
        ],
      );

  // ─── Score Indicators ───────────────────────────────────────

  static const double scoreIndicatorWidth = 48.0;
  static const double scoreIndicatorHeight = 32.0;
  static const double scoreIndicatorRadius = 16.0;

  static BoxDecoration get scoreIndicator => BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(scoreIndicatorRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      );

  // ═══════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════

  static const double iconXS = 16.0;
  static const double iconSM = 18.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double icon2XL = 40.0;
  static const double icon3XL = 48.0;

  static const double strokeThin = 1.0;
  static const double strokeNormal = 1.5;
  static const double strokeBold = 2.0;

  // ═══════════════════════════════════════════════════════════════
  // ANIMATION & TRANSITIONS
  // ═══════════════════════════════════════════════════════════════

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 800);

  // ═══════════════════════════════════════════════════════════════
  // Z-INDEX / ELEVATION LAYERS
  // ═══════════════════════════════════════════════════════════════

  static const double zIndexBase = 0;
  static const double zIndexCard = 1;
  static const double zIndexNavigation = 10;
  static const double zIndexMiniPlayer = 15;
  static const double zIndexModal = 40;
  static const double zIndexNowPlaying = 50;
  static const double zIndexToast = 100;

  // ═══════════════════════════════════════════════════════════════
  // BREAKPOINTS (Responsive Design)
  // ═══════════════════════════════════════════════════════════════

  static const double breakpointSM = 640.0;
  static const double breakpointMD = 768.0;
  static const double breakpointLG = 1024.0;
  static const double breakpointXL = 1280.0;

  // ═══════════════════════════════════════════════════════════════
  // SAFE AREA INSETS (defaults, use MediaQuery in practice)
  // ═══════════════════════════════════════════════════════════════

  static const double safeAreaTop = 44.0;
  static const double safeAreaBottom = 34.0;
  static const double safeAreaSides = 0.0;
}
