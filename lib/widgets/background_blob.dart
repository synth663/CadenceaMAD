import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// Blurred red circle for atmospheric background effect.
/// Matches the background blur blob in Welcome.tsx, NowPlaying.tsx, etc.
class BackgroundBlob extends StatelessWidget {
  final double size;
  final Offset offset;
  final double opacity;

  const BackgroundBlob({
    super.key,
    this.size = 384.0, // w-96 (24rem)
    this.offset = Offset.zero,
    this.opacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.translate(
          offset: Offset(offset.dx, 0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed.withValues(alpha: opacity),
            ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: AppDecorations.blurStrong,
                sigmaY: AppDecorations.blurStrong,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryRed.withValues(alpha: opacity),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
