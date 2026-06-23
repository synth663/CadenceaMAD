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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: Consumer<CatalogProvider>(
          builder: (context, catalog, child) {
            final isLoading = catalog.isLoading && !catalog.hasFetched;
            final allSongs = catalog.songs;
            final recentlyPlayed = allSongs.take(4).toList();
            final trendingSongs = allSongs.skip(4).take(4).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32.0),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover',
                              style: AppTextStyles.h1.copyWith(
                                color: const Color(0xFFE88219),
                                fontWeight: FontWeight.w700,
                                fontSize: 32.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Start your karaoke journey',
                              style: AppTextStyles.bodySM.copyWith(color: Colors.white54),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E2621),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.bell, color: Colors.white, size: 20.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  
                  // Recently Played Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recently Played',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/recently-played'),
                          child: Text(
                            'See all',
                            style: AppTextStyles.bodySM.copyWith(
                              color: const Color(0xFFE88219),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Recently Played Carousel
                  SizedBox(
                    height: 140.0,
                    child: isLoading
                        ? _buildHorizontalShimmer()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: recentlyPlayed.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16.0),
                            itemBuilder: (context, index) {
                              final song = recentlyPlayed[index];
                              return _buildHorizontalSongCard(context, song);
                            },
                          ),
                  ),
                  const SizedBox(height: 48.0),
                  
                  // Trending Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'See all',
                            style: AppTextStyles.bodySM.copyWith(
                              color: const Color(0xFFE88219),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Trending List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: isLoading
                        ? _buildVerticalShimmer()
                        : Column(
                            children: trendingSongs.map((song) {
                              return _buildVerticalSongCard(context, song);
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 48.0),
                  
                  // All Songs Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Songs',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/all-songs'),
                          child: Text(
                            'See all',
                            style: AppTextStyles.bodySM.copyWith(
                              color: const Color(0xFFE88219),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // All Songs Carousel
                  SizedBox(
                    height: 140.0,
                    child: isLoading
                        ? _buildHorizontalShimmer()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: allSongs.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16.0),
                            itemBuilder: (context, index) {
                              final song = allSongs[index];
                              return _buildHorizontalSongCard(context, song);
                            },
                          ),
                  ),
                  const SizedBox(height: 180.0), // Padding for bottom nav bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalSongCard(BuildContext context, Song song) {
    return GestureDetector(
      onTap: () {
        context.read<PlayerProvider>().playSong(song);
        context.push('/now-playing');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 104.0,
            height: 104.0,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2621),
              borderRadius: BorderRadius.circular(16.0),
              image: song.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(song.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: song.imageUrl == null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: song.gradientColors,
                      ),
                    ),
                    child: const Icon(LucideIcons.music, color: Colors.white54, size: 32),
                  )
                : null,
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 104.0,
            child: Text(
              song.title,
              style: AppTextStyles.bodySM.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSongCard(BuildContext context, Song song) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerProvider>().playSong(song);
          context.push('/now-playing');
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2621),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              // Album Art
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: const Color(0xFF2E2621),
                  image: song.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(song.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: song.imageUrl == null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          gradient: LinearGradient(
                            colors: song.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(LucideIcons.music, color: Colors.white54, size: 20),
                      )
                    : null,
              ),
              const SizedBox(width: 16.0),
              // Title & Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: AppTextStyles.bodySM.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      song.artist,
                      style: AppTextStyles.caption.copyWith(color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              // Stats & Duration
              Row(
                children: [
                  const Icon(LucideIcons.headphones, color: Colors.white54, size: 14.0),
                  const SizedBox(width: 4.0),
                  Text(
                    song.plays ?? '0M',
                    style: AppTextStyles.caption.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    song.formattedDuration,
                    style: AppTextStyles.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 16.0),
      itemBuilder: (_, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: const Color(0xFF2E2621),
              highlightColor: const Color(0xFF3E3631),
              child: Container(
                width: 104.0,
                height: 104.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Shimmer.fromColors(
              baseColor: const Color(0xFF2E2621),
              highlightColor: const Color(0xFF3E3631),
              child: Container(
                width: 80.0,
                height: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalShimmer() {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Shimmer.fromColors(
            baseColor: const Color(0xFF2E2621),
            highlightColor: const Color(0xFF3E3631),
            child: Container(
              height: 72.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        );
      }),
    );
  }
}
