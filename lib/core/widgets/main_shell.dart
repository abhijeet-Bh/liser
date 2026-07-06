import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:liser/features/player/presentation/widgets/expandable_player.dart';

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

          // The morphing player and nav bar
          ExpandablePlayer(
            bottomNavigationBar: ClipRect(
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
                          icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.home)),
                          activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.house_fill)),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.music_albums)),
                          activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.music_albums_fill)),
                          label: 'Library',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.settings)),
                          activeIcon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(CupertinoIcons.settings_solid)),
                          label: 'Settings',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
