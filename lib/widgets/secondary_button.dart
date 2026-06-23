import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

/// Secondary/ghost button with glass background and border.
/// Matches the "Sign In" button in Welcome.tsx.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = AppDecorations.buttonHeightPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: AppDecorations.buttonSecondary,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDecorations.radiusButton),
          onTap: onPressed,
          child: Center(
            child: Text(text, style: AppTextStyles.buttonSecondary),
          ),
        ),
      ),
    );
  }
}
