import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

/// Primary CTA button with gradient background and shadow.
/// Matches the "Get Started" button in Welcome.tsx.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = AppDecorations.buttonHeightPrimary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: AppDecorations.durationNormal,
        height: height,
        decoration: AppDecorations.buttonPrimary,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDecorations.radiusButton),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(text, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
