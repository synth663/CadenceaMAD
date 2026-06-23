import 'package:flutter/material.dart';
import 'mini_player.dart';
import 'bottom_nav_bar.dart';

/// Main scaffold holding tab content + MiniPlayer + BottomNavBar.
/// Matches Root.tsx layout — content scrolls, mini player and nav are fixed.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onMiniPlayerTap;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabChanged,
    this.onMiniPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content — scrolls behind the floating bottom elements
        Positioned.fill(
          child: child,
        ),
        // Floating bottom elements
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MiniPlayer(onTap: onMiniPlayerTap),
                const SizedBox(height: 12.0),
                BottomNavBar(
                  currentIndex: currentIndex,
                  onTap: onTabChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
