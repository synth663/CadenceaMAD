import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Cadencea Typography
class AppTextStyles {
  AppTextStyles._();

  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;

  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.625;
  static const double lineHeightLoose = 2.0;

  // Helper for applying -2% letter spacing
  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double height = lineHeightNormal,
    required Color color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: fontSize * -0.02,
    );
  }

  static TextStyle get h1 => _inter(fontSize: fontSize4XL, fontWeight: fontWeightMedium, color: AppColors.textPrimary);
  static TextStyle get h2 => _inter(fontSize: fontSize3XL, fontWeight: fontWeightMedium, color: AppColors.textPrimary);
  static TextStyle get h3 => _inter(fontSize: fontSize2XL, fontWeight: fontWeightMedium, color: AppColors.textPrimary);
  static TextStyle get h4 => _inter(fontSize: fontSizeXL, fontWeight: fontWeightMedium, color: AppColors.textPrimary);
  
  static TextStyle get body => _inter(fontSize: fontSizeBase, fontWeight: fontWeightNormal, color: AppColors.textPrimary);
  static TextStyle get bodyLarge => _inter(fontSize: fontSizeLG, fontWeight: fontWeightNormal, color: AppColors.textPrimary);
  static TextStyle get bodySM => _inter(fontSize: fontSizeSM, fontWeight: fontWeightNormal, color: AppColors.textPrimary);
  static TextStyle get caption => _inter(fontSize: fontSizeXS, fontWeight: fontWeightNormal, color: AppColors.textMuted);
  
  static TextStyle get button => _inter(fontSize: fontSizeBase, fontWeight: fontWeightBold, color: AppColors.textWhite);
  static TextStyle get buttonSecondary => _inter(fontSize: fontSizeBase, fontWeight: fontWeightSemibold, color: AppColors.textWhite);
  
  static TextStyle get label => _inter(fontSize: fontSizeSM, fontWeight: fontWeightMedium, color: AppColors.textPrimary);
  static TextStyle get input => _inter(fontSize: fontSizeBase, fontWeight: fontWeightNormal, color: AppColors.textWhite);
  static TextStyle get inputPlaceholder => _inter(fontSize: fontSizeBase, fontWeight: fontWeightNormal, color: AppColors.textDisabled);
  
  static TextStyle get navBarActive => _inter(fontSize: fontSizeXS, fontWeight: fontWeightSemibold, color: AppColors.primaryRed);
  static TextStyle get navBarInactive => _inter(fontSize: fontSizeXS, fontWeight: fontWeightMedium, color: AppColors.textMuted);
}
