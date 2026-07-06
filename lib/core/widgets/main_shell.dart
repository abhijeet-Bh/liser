import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/features/player/presentation/widgets/mini_player.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // The main content of the current tab
          navigationShell,

          // The bottom UI elements
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MiniPlayer sits just above the nav bar with slight padding
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: MiniPlayer(),
                ),

                // Full-width glassmorphic navigation bar
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.75),
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: BottomNavigationBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          type: BottomNavigationBarType.fixed,
                          currentIndex: navigationShell.currentIndex,
                          onTap: _onTap,
                          selectedItemColor: theme.colorScheme.primary,
                          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          selectedFontSize: 12,
                          unselectedFontSize: 12,
                          items: const [
                            BottomNavigationBarItem(
                              icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.home_outlined)),
                              activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.home_rounded)),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.library_music_outlined)),
                              activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.library_music_rounded)),
                              label: 'Library',
                            ),
                            BottomNavigationBarItem(
                              icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.settings_outlined)),
                              activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.settings_rounded)),
                              label: 'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
