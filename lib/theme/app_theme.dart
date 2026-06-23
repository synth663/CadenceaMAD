import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decorations.dart';

/// Cadencea Theme — from DESIGN_TOKENS.md
/// Dark ThemeData with custom ColorScheme, text theme, and input decoration theme.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ─── Color Scheme ─────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryRed,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.primaryRedDark,
        onSecondary: AppColors.textWhite,
        error: AppColors.destructive,
        onError: AppColors.textWhite,
        surface: AppColors.backgroundPrimary,
        onSurface: AppColors.textPrimary,
      ),

      // ─── Scaffold ─────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      // ─── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDecorations.iconLG,
        ),
      ),

      // ─── Text Theme ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 36.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 30.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.dmSans(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),

      // ─── Input Decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 48.0,
          vertical: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusInput),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusInput),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusInput),
          borderSide: BorderSide(
            color: AppColors.primaryRed.withValues(alpha: 0.5),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusInput),
          borderSide: BorderSide(
            color: AppColors.destructive.withValues(alpha: 0.5),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusInput),
          borderSide: BorderSide(
            color: AppColors.destructive.withValues(alpha: 0.5),
          ),
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textDisabled,
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        errorStyle: GoogleFonts.dmSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: AppColors.destructive,
        ),
      ),

      // ─── Card Theme ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusCard),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),

      // ─── Bottom Navigation ────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundPrimary,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ─── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1.0,
      ),

      // ─── Splash ───────────────────────────────────────────────
      splashColor: AppColors.primaryRed.withValues(alpha: 0.1),
      highlightColor: AppColors.primaryRed.withValues(alpha: 0.05),
    );
  }
}
