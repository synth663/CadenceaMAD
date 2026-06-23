import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';
import '../providers/player_provider.dart';
import '../providers/scoring_provider.dart';
import '../widgets/background_blob.dart';
import '../widgets/metric_bar.dart';

/// Now Playing screen — 1:1 conversion of NowPlaying.tsx.
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});
  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final _lyrics = [
    'City lights are fading slow', 'Underneath the neon glow', 'Dancing through the midnight rain',
    'Chasing dreams we can\'t explain', 'In this moment, we\'re alive', 'Feel the rhythm, feel the vibe',
    'Midnight dreams will never fade', 'In the shadows that we\'ve made', 'Hearts are beating through the night',
    'Everything just feels so right', 'Lost in time, we\'re floating free', 'This is where we\'re meant to be',
    'Midnight dreams, electric skies', 'See the wonder in your eyes', 'Never let this feeling go', 'In the city\'s midnight glow',
  ];
  int _activeLyricIndex = 5; // matching NowPlaying.tsx

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scoring = context.read<ScoringProvider>();
      final player = context.read<PlayerProvider>();
      if (player.isPlaying) scoring.startScoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final scoring = context.watch<ScoringProvider>();
    final song = player.currentSong;
    final title = song?.title ?? 'Midnight Dreams';
    final artist = song?.artist ?? 'Aurora Bay';
    final colors = song?.gradientColors ?? [AppColors.primaryRed, AppColors.primaryRedDark];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppDecorations.gradientBackground),
        child: Stack(children: [
          const BackgroundBlob(offset: Offset(0, -160)),
          SafeArea(child: Column(children: [
            // Header
            Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), child: Row(children: [
              _iconBtn(LucideIcons.chevronDown, () => context.pop()),
              Expanded(child: Column(children: [
                Text('PLAYING FROM PLAYLIST', style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
                const SizedBox(height: 4.0),
                Text('Midnight Vibes', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600)),
              ])),
              _iconBtn(LucideIcons.moreHorizontal, () {}),
            ])),
            // Album Artwork
            Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: AspectRatio(aspectRatio: 1.0, child: Stack(children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors), borderRadius: BorderRadius.circular(24.0), boxShadow: const [AppDecorations.shadow2XL])),
              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.0), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.transparent, Color(0x66000000)], stops: [0.0, 0.5, 1.0]))),
            ]))),
            const SizedBox(height: 32.0),
            // Song Info
            Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8.0),
                Text(artist, style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              ])),
              _iconBtn(player.isLiked ? LucideIcons.heart : LucideIcons.heart, () => player.toggleLike(), filled: player.isLiked),
            ])),
            const SizedBox(height: 24.0),
            // Progress Bar
            Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: Column(children: [
              SliderTheme(data: SliderThemeData(trackHeight: 4.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), activeTrackColor: Colors.white, inactiveTrackColor: Colors.white.withValues(alpha: 0.1), thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay),
                child: Slider(value: player.progress.clamp(0.0, 1.0), onChanged: (v) => player.seekTo((v * player.totalDuration).toInt()))),
              const SizedBox(height: 4.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(player.currentTimeFormatted, style: AppTextStyles.caption),
                Text(player.totalDurationFormatted, style: AppTextStyles.caption),
              ]),
            ])),
            const SizedBox(height: 16.0),
            // Playback Controls
            Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Icon(LucideIcons.shuffle, size: 22.0, color: AppColors.textMuted),
              GestureDetector(onTap: () => player.skipBack(), child: const Icon(LucideIcons.skipBack, size: 32.0, color: Colors.white)),
              GestureDetector(onTap: () {
                player.togglePlayPause();
                if (player.isPlaying) { scoring.startScoring(); } else { scoring.stopScoring(); }
              }, child: Container(width: 64.0, height: 64.0, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [AppDecorations.shadow2XL]),
                child: Icon(player.isPlaying ? LucideIcons.pause : LucideIcons.play, size: 24.0, color: Colors.black))),
              GestureDetector(onTap: () => player.skipForward(), child: const Icon(LucideIcons.skipForward, size: 32.0, color: Colors.white)),
              Icon(LucideIcons.repeat, size: 22.0, color: AppColors.textMuted),
            ])),
            const SizedBox(height: 16.0),
            // Scoring Panel
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: Column(children: [
              _buildScoringPanel(scoring),
              const SizedBox(height: 16.0),
              _buildLyrics(),
              const SizedBox(height: 16.0),
            ]))),
          ])),
          // FAB Record button
          Positioned(bottom: 32, right: 32, child: GestureDetector(onTap: () => context.push('/recording'),
            child: Container(width: 56.0, height: 56.0, decoration: BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle, boxShadow: const [AppDecorations.shadow2XL]),
              child: const Icon(LucideIcons.mic, size: 22.0, color: Colors.white)))),
          // Performance report prompt when paused
          if (!player.isPlaying) Positioned(bottom: 100, left: 24, right: 24,
            child: GestureDetector(onTap: () => context.push('/performance-report'),
              child: Container(padding: const EdgeInsets.all(16.0), decoration: BoxDecoration(gradient: AppDecorations.gradientPrimary, borderRadius: BorderRadius.circular(16.0), boxShadow: const [AppDecorations.shadow2XL]),
                child: Row(children: [
                  const Icon(LucideIcons.activity, size: 20.0, color: Colors.white),
                  const SizedBox(width: 12.0),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('View Performance Report', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700)),
                    Text('See your detailed analysis', style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9999.0)),
                    child: Row(children: [
                      const Icon(LucideIcons.trendingUp, size: 14.0, color: Colors.white),
                      const SizedBox(width: 4.0),
                      Text('${scoring.overallScore}%', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700)),
                    ])),
                ])))),
        ])),
    );
  }

  Widget _buildScoringPanel(ScoringProvider scoring) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.4), Colors.black.withValues(alpha: 0.2)]),
        borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.white.withValues(alpha: 0.1)), boxShadow: const [AppDecorations.shadow2XL]),
      child: Column(children: [
        Row(children: [
          const Icon(LucideIcons.activity, size: 16.0, color: AppColors.primaryRed),
          const SizedBox(width: 8.0),
          Text('LIVE VOCAL SCORING', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9999.0), border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(LucideIcons.trendingUp, size: 14.0, color: AppColors.primaryRed),
              const SizedBox(width: 4.0),
              Text('${scoring.overallScore}%', style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700, color: AppColors.primaryRed)),
            ])),
        ]),
        const SizedBox(height: 16.0),
        // Pitch with deviation bar
        MetricBar(label: 'Pitch', icon: LucideIcons.music, percentage: scoring.pitchAccuracy, color: const Color(0xFF4ADE80)),
        const SizedBox(height: 8.0),
        _pitchDeviationBar(scoring.pitchDeviation),
        const SizedBox(height: 12.0),
        MetricBar(label: 'Timing', icon: LucideIcons.clock, percentage: scoring.timingAccuracy, color: const Color(0xFF60A5FA), subtitle: scoring.timingOffsetText),
        const SizedBox(height: 12.0),
        MetricBar(label: 'Tempo', icon: LucideIcons.activity, percentage: scoring.tempoAlignment, color: const Color(0xFFF59E0B)),
        const SizedBox(height: 12.0),
        MetricBar(label: 'Volume', icon: LucideIcons.volume2, percentage: scoring.volumeConsistency, color: const Color(0xFFA78BFA)),
      ]),
    );
  }

  Widget _pitchDeviationBar(int deviation) {
    return Container(height: 32.0, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Stack(children: [
        Center(child: Container(width: 1.0, color: Colors.white.withValues(alpha: 0.3))),
        AnimatedPositioned(duration: const Duration(milliseconds: 200), left: 0, right: 0, top: 0, bottom: 0,
          child: Center(child: Transform.translate(offset: Offset(deviation.toDouble() * 1.5, 0),
            child: Container(width: 4.0, height: 24.0, decoration: BoxDecoration(color: const Color(0xFF4ADE80), borderRadius: BorderRadius.circular(2.0), boxShadow: [BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.5), blurRadius: 8.0)]))))),
        Positioned.fill(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('♭', style: TextStyle(fontSize: 10.0, color: AppColors.textMuted)),
          Text('Perfect', style: TextStyle(fontSize: 10.0, color: Colors.white.withValues(alpha: 0.5))),
          Text('♯', style: TextStyle(fontSize: 10.0, color: AppColors.textMuted)),
        ]))),
      ]));
  }

  Widget _buildLyrics() {
    return Container(padding: const EdgeInsets.all(24.0), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24.0), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: _lyrics.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(e.value, textAlign: TextAlign.center,
          style: e.key == _activeLyricIndex
              ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: Colors.white)
              : AppTextStyles.body.copyWith(color: AppColors.textMuted)))).toList()));
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(onTap: onTap, child: Container(width: 40.0, height: 40.0, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Icon(icon, size: 20.0, color: filled ? AppColors.primaryRed : Colors.white)));
  }
}
