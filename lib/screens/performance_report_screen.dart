import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/recording.dart';

/// Performance Report screen — shows detailed analysis for a recording.
/// Accepts an optional Recording to display dynamic data; falls back to defaults.
class PerformanceReportScreen extends StatelessWidget {
  final Recording? recording;

  const PerformanceReportScreen({super.key, this.recording});

  @override
  Widget build(BuildContext context) {
    final overall = recording?.score ?? 87;
    final pitch = recording?.pitchPercent ?? 92;
    final timing = recording?.timingPercent ?? 85;
    final tone = recording?.tonePercent ?? 84;
    final tempo = 84;
    final volume = 88;
    final songTitle = recording?.songTitle ?? 'Midnight Dreams';
    final artist = recording?.artist ?? 'Aurora Bay';

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Performance Report', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('$songTitle • $artist', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: const Color(0xFF2E2621),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'save') {
                          context.push('/my-recordings');
                        } else if (value == 'share') {
                          // Share action
                        }
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(LucideIcons.moreHorizontal, size: 20, color: Colors.white),
                      ),
                      offset: const Offset(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.download, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              Text('Save recording', style: AppTextStyles.bodySM.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.share2, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              Text('Share recording', style: AppTextStyles.bodySM.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sleek Overall Score Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryRed.withValues(alpha: 0.2),
                            AppColors.primaryRed.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/my-recordings'),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryRed.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(LucideIcons.play, size: 28, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OVERALL SCORE',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$overall', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0)),
                                    const SizedBox(width: 12),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(9999),
                                        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.trendingUp, size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(_overallLabel(overall), style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Performance Breakdown Grid
                    Text('Performance Breakdown', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _metricTile('Pitch', pitch, LucideIcons.music, const Color(0xFF4ADE80)),
                        _metricTile('Timing', timing, LucideIcons.clock, const Color(0xFF60A5FA)),
                        _metricTile('Tone', tone, LucideIcons.mic, const Color(0xFFA78BFA)),
                        _metricTile('Volume', volume, LucideIcons.volume2, const Color(0xFFF59E0B)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Pitch Analysis
                    Text('Pitch Analysis', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _legendDot(const Color(0xFF4ADE80), 'Your Pitch'),
                              const SizedBox(width: 16),
                              _legendDot(Colors.white, 'Original'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(color: AppColors.backgroundPrimary, borderRadius: BorderRadius.circular(12)),
                            child: CustomPaint(size: const Size(double.infinity, 100), painter: _PitchGraphPainter()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Timing Analysis
                    Text('Timing Analysis', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _legendDot(const Color(0xFF60A5FA), 'Early'),
                              const SizedBox(width: 16),
                              _legendDot(const Color(0xFFF59E0B), 'Late'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 75,
                            decoration: BoxDecoration(color: AppColors.backgroundPrimary, borderRadius: BorderRadius.circular(12)),
                            child: CustomPaint(size: const Size(double.infinity, 75), painter: _TimingBarsPainter()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Feedback
                    Text('Performance Feedback', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        _feedbackText(overall),
                        style: AppTextStyles.bodySM.copyWith(color: Colors.white, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _overallLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Great';
    if (score >= 70) return 'Good';
    return 'Keep Practicing';
  }

  static String _feedbackText(int score) {
    if (score >= 90) {
      return 'Outstanding performance! Your pitch accuracy and timing were near-perfect. You\'re ready to take on more challenging pieces!';
    } else if (score >= 80) {
      return 'Great job! Your pitch accuracy was impressive and your timing was solid. Keep practicing to reach perfection!';
    } else if (score >= 70) {
      return 'Good effort! Focus on maintaining consistent pitch and timing. A little more practice will take you to the next level!';
    }
    return 'Keep at it! Regular practice will help you improve your vocal technique. Try slowing down and focusing on one metric at a time.';
  }

  static Widget _metricTile(String label, int value, IconData icon, Color color) {
    final bgColors = [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgColors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const Spacer(),
          Text('$value%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  static Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _PitchGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    // Original pitch (white)
    final p1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path1 = Path();
    for (double x = 0; x < size.width; x += 2) {
      final y = size.height / 2 + sin((x / size.width) * pi * 4) * (size.height / 6);
      x == 0 ? path1.moveTo(x, y) : path1.lineTo(x, y);
    }
    canvas.drawPath(path1, p1);
    // User pitch (green)
    final p2 = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path2 = Path();
    for (double x = 0; x < size.width; x += 2) {
      final dev = (rng.nextDouble() - 0.5) * 0.3;
      final y = size.height / 2 + sin((x / size.width) * pi * 4) * (size.height / 6) + dev * (size.height / 4);
      x == 0 ? path2.moveTo(x, y) : path2.lineTo(x, y);
    }
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TimingBarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final barCount = 40;
    final barWidth = size.width / barCount;
    for (int i = 0; i < barCount; i++) {
      final offset = (rng.nextDouble() - 0.5) * size.height;
      final barHeight = offset.abs();
      final isEarly = offset < 0;
      final paint = Paint()..color = isEarly ? const Color(0xFF60A5FA) : const Color(0xFFF59E0B);
      canvas.drawRect(Rect.fromLTWH(i * barWidth, size.height / 2 - (isEarly ? barHeight : 0), barWidth - 1, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
