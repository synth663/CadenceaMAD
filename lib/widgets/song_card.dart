import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Album art grid card with gradient background and title overlay.
/// Matches the "Recently Played" song cards in Home.tsx.
class SongCard extends StatelessWidget {
  final String title;
  final String artist;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 10),
                        blurRadius: 15.0,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                ),
                // Dark overlay at bottom
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x66000000),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // Song info
          Text(
            title,
            style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),
          Text(
            artist,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
