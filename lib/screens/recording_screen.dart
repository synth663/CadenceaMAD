import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/recording_provider.dart';

/// Recording screen — 1:1 conversion of Recording.tsx with waveform CustomPainter.
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});
  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final rec = context.watch<RecordingProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), child: Row(children: [
          GestureDetector(onTap: () { rec.reset(); context.pop(); },
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: const Icon(LucideIcons.x, size: 20, color: Colors.white))),
          Expanded(child: Column(children: [
            Text('Record & Mix', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Midnight Dreams', style: AppTextStyles.caption),
          ])),
          const SizedBox(width: 40),
        ])),
        // Waveform
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)]),
            borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Stack(children: [
            AnimatedBuilder(animation: _animCtrl, builder: (context, child) => CustomPaint(
              size: Size.infinite, painter: _WaveformPainter(time: _animCtrl.value * 10, isRecording: rec.isRecording, hasRecording: rec.hasRecording, micLevel: rec.micLevel))),
            Center(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.2))),
            if (rec.isRecording) Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9999), border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('RECORDING', style: AppTextStyles.caption.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.w600)),
              ]))),
            if (rec.isRecording) Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(9999), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: Text('Scoring Active', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)))),
          ]))))),
        const SizedBox(height: 24),
        // Mic Level
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(LucideIcons.mic, size: 16, color: AppColors.textMuted), const SizedBox(width: 12), Text('Input Level', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Container(height: 8, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(4)),
              child: LayoutBuilder(builder: (_, c) => Stack(children: [
                AnimatedContainer(duration: const Duration(milliseconds: 100), width: c.maxWidth * rec.micLevel, height: 8,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFFFACC15), Color(0xFFFA233B)]), borderRadius: BorderRadius.circular(4))),
              ]))),
          ]))),
        const SizedBox(height: 16),
        // Mix controls
        if (rec.hasRecording) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: Column(children: [
            _volumeSlider('Vocals', rec.vocalVolume, (v) => rec.setVocalVolume(v)),
            const SizedBox(height: 16),
            _volumeSlider('Instrumental', rec.instrumentalVolume, (v) => rec.setInstrumentalVolume(v)),
          ]))),
        const SizedBox(height: 24),
        // Record button
        Center(child: GestureDetector(onTap: () { rec.isRecording ? rec.stopRecording() : rec.startRecording(); },
          child: Container(width: 80, height: 80, decoration: BoxDecoration(color: rec.isRecording ? AppColors.primaryRed : Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 8), blurRadius: 24)]),
            child: rec.isRecording
                ? const Icon(LucideIcons.square, size: 28, color: Colors.white)
                : Center(child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle)))))),
        const SizedBox(height: 16),
        // Playback & Export
        if (rec.hasRecording) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _pillBtn(LucideIcons.play, 'Play Mix', false, () {}),
          const SizedBox(width: 12),
          _pillBtn(LucideIcons.download, 'Save Recording', true, () => context.pushReplacement('/my-recordings')),
        ])),
        const SizedBox(height: 32),
      ])),
    );
  }

  Widget _volumeSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600)),
        Text('${(value * 100).round()}%', style: AppTextStyles.caption),
      ]),
      const SizedBox(height: 8),
      SliderTheme(data: SliderThemeData(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), activeTrackColor: Colors.white, inactiveTrackColor: Colors.black.withValues(alpha: 0.4), thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay),
        child: Slider(value: value, onChanged: onChanged)),
    ]);
  }

  Widget _pillBtn(IconData icon, String label, bool primary, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: primary ? AppColors.primaryRed : Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9999), border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: primary ? const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 12)] : null),
      child: Row(children: [Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8), Text(label, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600))])));
  }
}

class _WaveformPainter extends CustomPainter {
  final double time; final bool isRecording, hasRecording; final double micLevel;
  _WaveformPainter({required this.time, required this.isRecording, required this.hasRecording, required this.micLevel});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isRecording && !hasRecording) return;
    final amplitude = isRecording ? micLevel : 0.5;
    // Primary waveform (red)
    final paint1 = Paint()..color = const Color(0xFFFA233B)..strokeWidth = 2..style = PaintingStyle.stroke;
    final path1 = Path();
    for (double x = 0; x < size.width; x += 2) {
      final y = size.height / 2 + sin((x * 0.01 + time * 2) * pi) * (size.height / 4) * amplitude;
      x == 0 ? path1.moveTo(x, y) : path1.lineTo(x, y);
    }
    canvas.drawPath(path1, paint1);
    // Secondary waveform (gray)
    final paint2 = Paint()..color = const Color(0xFF4A4A4A)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path2 = Path();
    for (double x = 0; x < size.width; x += 2) {
      final y = size.height / 2 + sin((x * 0.008 + time * 1.5) * pi) * (size.height / 4) * 0.3;
      x == 0 ? path2.moveTo(x, y) : path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => true;
}
