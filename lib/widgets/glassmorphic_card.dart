import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';

/// Reusable glassmorphic card with backdrop blur, white/5 fill, and white/10 border.
/// Matches the glass-effect containers used throughout the app.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurAmount;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppDecorations.radiusCard,
    this.blurAmount = AppDecorations.blurMedium,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDecorations.cardPadding),
          decoration: AppDecorations.cardGlass,
          child: child,
        ),
      ),
    );
  }
}
