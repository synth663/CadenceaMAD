import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/catalog_provider.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  String? _activeGenre;

  static const List<String> _genres = [
    'All',
    'Pop',
    'Rock',
    'R&B',
    'Electronic',
    'Indie',
    'Jazz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B), // Nero 950
      body: Consumer<CatalogProvider>(
        builder: (context, catalog, child) {
          final isLoading = catalog.isLoading && !catalog.hasFetched;
          final songs = catalog.songs;

          return CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.chevronLeft,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'All Songs',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Song count
                        Text(
                          isLoading ? '...' : '${songs.length} songs',
                          style: AppTextStyles.bodySM.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action row: playlist art + download + shuffle + play
                        Row(
                          children: [
                            // Matte placeholder for list
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFF2E2621), // Sandrift 950
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Icon(
                                LucideIcons.music,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            // Shuffle
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                LucideIcons.shuffle,
                                size: 24,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Play button
                            GestureDetector(
                              onTap: () {
                                if (songs.isNotEmpty) {
                                  context.read<PlayerProvider>().playSong(songs.first);
                                  context.push('/now-playing');
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE88219), // Zest 500
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE88219).withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.play,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Genre Filter Chips ────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final genre = _genres[i];
                      final isActive = _activeGenre == genre ||
                          (genre == 'All' && _activeGenre == null);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeGenre = genre == 'All' ? null : genre;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE88219)
                                : const Color(0xFF2E2621),
                            borderRadius: BorderRadius.circular(20),
                            border: isActive
                                ? null
                                : Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              genre,
                              style: AppTextStyles.bodySM.copyWith(
                                fontWeight:
                                    isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ─── Song List ─────────────────────────────────────────
              isLoading
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildVerticalShimmer(),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= songs.length) return null;
                          final song = songs[index];
                          // Add extra bottom padding for the last few items
                          // so content isn't hidden behind mini player + nav
                          final isLast = index == songs.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isLast ? 180 : 0,
                            ),
                            child: _SongListItem(
                              song: song,
                              onTap: () {
                                context.read<PlayerProvider>().playSong(song);
                                context.push('/now-playing');
                              },
                            ),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerticalShimmer() {
    return Column(
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: const Color(0xFF2E2621),
                highlightColor: const Color(0xFF3E3631),
                child: Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: const Color(0xFF2E2621),
                      highlightColor: const Color(0xFF3E3631),
                      child: Container(
                        width: double.infinity,
                        height: 14.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Shimmer.fromColors(
                      baseColor: const Color(0xFF2E2621),
                      highlightColor: const Color(0xFF3E3631),
                      child: Container(
                        width: 120.0,
                        height: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const _SongListItem({required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Album art - matte look without neon gradient
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2E2621), // Sandrift 950
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: song.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          LucideIcons.music,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : Icon(
                      LucideIcons.music,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
            ),
            const SizedBox(width: 16),
            // Title and artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodySM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Three-dot menu
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  LucideIcons.moreVertical,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
