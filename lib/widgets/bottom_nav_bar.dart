import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [LucideIcons.home, LucideIcons.search, LucideIcons.library, LucideIcons.user];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
        child: Container(
          height: 64.0,
          decoration: BoxDecoration(
            color: const Color(0xFF2E2621),
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              final active = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  child: Icon(
                    icons[i],
                    size: 24.0,
                    color: active ? const Color(0xFFE88219) : Colors.white54,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
