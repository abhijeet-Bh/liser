import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liser/core/constants/app_constants.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double shrinkProgress;
  final Color activeColor;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.shrinkProgress,
    this.activeColor = const Color(0xFFEC4899), // Hot Pink accent
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedShrink = shrinkProgress.clamp(0.0, 1.0);
    
    final items = [
      _NavItem(icon: CupertinoIcons.home, activeIcon: CupertinoIcons.house_fill, label: 'Home'),
      _NavItem(icon: CupertinoIcons.music_albums, activeIcon: CupertinoIcons.music_albums_fill, label: 'Library'),
      _NavItem(icon: CupertinoIcons.settings, activeIcon: CupertinoIcons.settings_solid, label: 'Settings'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final minWidth = 60.0;
        final currentWidth = minWidth + (maxWidth - minWidth) * (1 - clampedShrink);

        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 60,
              width: currentWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Active indicator pill
                      // TweenAnimationBuilder doesn't need to be conditionally removed
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: currentIndex.toDouble()),
                        duration: AppDurations.normal,
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedIndex, child) {
                          return Positioned(
                            left: ((currentWidth / 3) * animatedIndex + 12) * (1 - clampedShrink) + 10 * clampedShrink,
                            width: ((currentWidth / 3) - 24) * (1 - clampedShrink) + (60.0 - 20) * clampedShrink, 
                            top: 10,
                            bottom: 10,
                            child: Opacity(
                              opacity: (1 - clampedShrink).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: activeColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  
                  // Icons
                  Stack(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isActive = currentIndex == index;
                      
                      // In shrink mode, hide non-active items
                      final itemOpacity = (isActive ? 1.0 : 1.0 - clampedShrink).clamp(0.0, 1.0);

                      final leftWhenFull = (currentWidth / 3) * index;
                      final widthWhenFull = currentWidth / 3;
                      
                      final currentItemLeft = isActive ? leftWhenFull * (1 - clampedShrink) : leftWhenFull;
                      final currentItemWidth = isActive 
                        ? widthWhenFull * (1 - clampedShrink) + 60.0 * clampedShrink
                        : widthWhenFull;

                      return Positioned(
                        left: currentItemLeft,
                        width: currentItemWidth,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: itemOpacity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (shrinkProgress > 0.5) return; 
                              onTap(index);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  color: isActive ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 1 - clampedShrink,
                                    child: Opacity(
                                      opacity: (1 - (clampedShrink * 2)).clamp(0.0, 1.0),
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                          color: isActive ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
