import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Performance Results screen — 1:1 conversion of PerformanceResults.tsx.
class PerformanceResultsScreen extends StatelessWidget {
  const PerformanceResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const score = 87;
    const pitch = 92; const timing = 85; const tone = 84;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), child: Row(children: [
          const SizedBox(width: 40),
          Expanded(child: Center(child: Text('Performance', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)))),
          GestureDetector(onTap: () => context.pop(),
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: const Icon(LucideIcons.x, size: 20, color: Colors.white))),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
          // Score Circle
          SizedBox(width: 192, height: 192, child: CustomPaint(
            painter: _ScoreCirclePainter(score: score),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
            ])))),
          const SizedBox(height: 24),
          Text('Great Performance!', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Midnight Dreams • Aurora Bay', style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 32),
          // Stats
          _statCard('Pitch Accuracy', pitch, LucideIcons.music, const Color(0xFF4ADE80)),
          const SizedBox(height: 12),
          _statCard('Timing', timing, LucideIcons.trendingUp, const Color(0xFF60A5FA)),
          const SizedBox(height: 12),
          _statCard('Tone Quality', tone, LucideIcons.mic, const Color(0xFFA78BFA)),
          const SizedBox(height: 32),
          // Achievement
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryRed.withValues(alpha: 0.2), AppColors.primaryRed.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.2))),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.star, size: 24, color: AppColors.primaryRed)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEW ACHIEVEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryRed, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text('Rising Star', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Score 85+ on 5 songs', style: AppTextStyles.caption),
              ])),
            ])),
          const SizedBox(height: 32),
          // Actions
          _actionBtn('Try Again', true, () {}),
          const SizedBox(height: 12),
          _actionBtn('Share Performance', false, () {}),
          const SizedBox(height: 32),
        ]))),
      ])),
    );
  }

  static Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(icon, size: 16, color: color)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('$value%', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Container(height: 6, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3)),
          child: LayoutBuilder(builder: (_, c) => Align(alignment: Alignment.centerLeft,
            child: Container(width: c.maxWidth * value / 100, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)))))),
      ]));
  }

  static Widget _actionBtn(String text, bool primary, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: primary ? AppColors.primaryRed : Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9999),
        border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: primary ? [const BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 12)] : null),
      child: Center(child: Text(text, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600)))));
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final int score;
  _ScoreCirclePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    // Background circle
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1A1A)..style = PaintingStyle.stroke..strokeWidth = 8);
    // Score arc
    final sweepAngle = (score / 100) * 2 * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false,
      Paint()..color = AppColors.primaryRed..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter old) => old.score != score;
}
