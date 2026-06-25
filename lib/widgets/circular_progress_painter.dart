import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a circular progress ring around the album art.
/// Background track is a thin muted circle; foreground arc shows progress.
/// A small thumb dot sits at the current progress angle.
class CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    this.trackColor = const Color(0x33D4A48D),
    this.progressColor = const Color(0xFFD4A48D),
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - (strokeWidth / 2);

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // 12 o'clock
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // Thumb dot at the progress position
      final thumbAngle = startAngle + sweepAngle;
      final thumbX = center.dx + radius * cos(thumbAngle);
      final thumbY = center.dy + radius * sin(thumbAngle);

      final thumbPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(thumbX, thumbY), strokeWidth * 1.8, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
