import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/player/presentation/widgets/expandable_player.dart';
import 'package:liser/core/widgets/floating_nav_bar.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  late AnimationController _shrinkController;
  final ValueNotifier<double> _playerExpandProgress = ValueNotifier(0.0);
  double _targetShrink = 0.0;

  @override
  void initState() {
    super.initState();
    _shrinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shrinkController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _handleScroll(ScrollNotification notification, bool hasSong) {
    if (!hasSong) {
      if (_targetShrink != 0.0) {
        _targetShrink = 0.0;
        _animateShrink(0.0);
      }
      return false;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        if (_targetShrink != 1.0) {
          _targetShrink = 1.0;
          _animateShrink(1.0);
        }
      } else if (notification.direction == ScrollDirection.forward) {
        if (_targetShrink != 0.0) {
          _targetShrink = 0.0;
          _animateShrink(0.0);
        }
      }
    }
    return false;
  }

  void _animateShrink(double target) {
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 300.0,
      damping: 28.0,
    );
    final simulation = SpringSimulation(
      spring,
      _shrinkController.value,
      target,
      0, // velocity
    );
    _shrinkController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return BlocBuilder<PlayerBloc, PlayerUiState>(
      builder: (context, state) {
        final hasSong = state.currentSong != null;
        
        // If there's no song, make sure the nav bar is expanded
        if (!hasSong && _targetShrink != 0.0) {
          _targetShrink = 0.0;
          _animateShrink(0.0);
        }

        return Scaffold(
          extendBody: true,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _handleScroll(notification, hasSong),
            child: Stack(
              children: [
                // The main content of the current tab
                widget.navigationShell,

                // The morphing player
                ExpandablePlayer(
                  shrinkProgress: _shrinkController,
                  expandProgress: _playerExpandProgress,
                ),

                // Floating Nav Bar
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: safeAreaBottom + 4.0,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _playerExpandProgress,
                    builder: (context, expandProgress, child) {
                      return Transform.translate(
                        offset: Offset(0, 100 * expandProgress),
                        child: Opacity(
                          opacity: (1 - expandProgress * 2).clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _shrinkController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingNavBar(
                            currentIndex: widget.navigationShell.currentIndex,
                            onTap: _onTap,
                            shrinkProgress: _shrinkController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
