import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> _recentSearches = [
    'Midnight Dreams',
    'Aurora Bay',
    'Electric Nights',
    'Neon Pulse',
    'Velvet Sky',
  ];

  static const List<String> _browseCategories = [
    'Pop',
    'Rock',
    'Jazz',
    'Karaoke',
    'Trending',
    'Favorites',
  ];

  static const List<Map<String, String>> _trendingSearches = [
    {'title': 'Shallow', 'artist': 'Lady Gaga'},
    {'title': 'Perfect', 'artist': 'Ed Sheeran'},
    {'title': 'Someone Like You', 'artist': 'Adele'},
    {'title': 'Shape of You', 'artist': 'Ed Sheeran'},
    {'title': 'Hallelujah', 'artist': 'Leonard Cohen'},
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_isFocused) {
        _showDropdown();
      } else {
        _hideDropdown();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _hideDropdown();
    super.dispose();
  }

  void _showDropdown() {
    if (_overlayEntry != null) return;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 48,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 56.0), // 48 height of textfield + 8 spacing
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2621),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_recentSearches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No recent searches',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ..._recentSearches.take(5).map((query) => _buildRecentSearchDropdownTile(query)),
                  if (_recentSearches.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 4.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _recentSearches.clear();
                            });
                            _hideDropdown();
                            _showDropdown(); // Rebuild with empty state
                          },
                          child: Text(
                            'Clear all',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFFE88219),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildRecentSearchDropdownTile(String query) {
    return InkWell(
      onTap: () {
        _searchController.text = query;
        _focusNode.unfocus();
        context.push('/now-playing'); // Mock navigation
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(LucideIcons.history, size: 16.0, color: AppColors.textMuted),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                query,
                style: AppTextStyles.bodySM.copyWith(color: Colors.white),
              ),
            ),
            Icon(LucideIcons.arrowUpLeft, size: 16.0, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Text(
                  'Search',
                  style: AppTextStyles.h1.copyWith(
                    color: const Color(0xFFE88219),
                    fontWeight: FontWeight.w700,
                    fontSize: 32.0,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2621),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Icon(LucideIcons.search, size: 20.0, color: Color(0xFFE88219)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: AppTextStyles.bodySM.copyWith(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Artists, songs, or albums',
                              hintStyle: AppTextStyles.bodySM.copyWith(color: Colors.white54),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(LucideIcons.x, size: 18.0, color: Colors.white54),
                            ),
                          )
                        else
                          const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32.0),

              // Browse All
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Browse All',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: _browseCategories.map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2621),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.bodySM.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 48.0),

              // Trending Searches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Trending Searches',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: List.generate(_trendingSearches.length, (index) {
                    final item = _trendingSearches[index];
                    final rank = index + 1;
                    return _buildTrendingSearchTile(rank, item['title']!, item['artist']!);
                  }),
                ),
              ),

              const SizedBox(height: 180.0), // Padding for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSearchTile(int rank, String title, String artist) {
    final isTop = rank == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2E2621),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Rank Circle
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isTop
                    ? const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF5252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                rank.toString(),
                style: AppTextStyles.bodySM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Title & Artist
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$title ',
                      style: AppTextStyles.bodySM.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '- $artist',
                      style: AppTextStyles.bodySM.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Trending Arrow
            Icon(
              LucideIcons.trendingUp,
              size: 16.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
