import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/core/utils/app_snackbar.dart';
import 'package:liser/core/constants/app_constants.dart';

class ExpandablePlayer extends StatefulWidget {
  final Widget? bottomNavigationBar;
  final Animation<double> shrinkProgress;
  final ValueNotifier<double>? expandProgress;

  const ExpandablePlayer({
    super.key,
    this.bottomNavigationBar,
    required this.shrinkProgress,
    this.expandProgress,
  });

  @override
  State<ExpandablePlayer> createState() => _ExpandablePlayerState();
}

class _ExpandablePlayerState extends State<ExpandablePlayer> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _miniPlayerOpacityAnimation;
  
  bool _isDragging = false;
  double _dragPosition = 0.0;
  late AnimationController _queueController;
  final double _miniPlayerHeight = 66.0; // Matched with FloatingNavBar
  bool _isQueueMode = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _controller.addListener(() {
      widget.expandProgress?.value = _controller.value;
    });
    _queueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addObserver(this);
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _queueController.dispose();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_controller.value > 0.0) {
      _controller.animateTo(0.0, curve: Curves.easeOutCubic, duration: AppDurations.fast);
      if (_isQueueMode) {
        setState(() {
          _isQueueMode = false;
          _queueController.reverse();
        });
      }
      return true;
    }
    return false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dragAmount = -details.primaryDelta! / screenHeight;
    _controller.value = (_controller.value + dragAmount).clamp(0.0, 1.0);
    
    // Auto-close queue mode when user swipes down to close player
    if (_controller.value < 0.9 && _isQueueMode) {
      setState(() {
        _isQueueMode = false;
        _queueController.reverse();
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    // primaryVelocity is pixels per second. Convert to controller fraction per second.
    // Dragging UP is negative velocity in Flutter, but means positive controller change.
    final velocity = -(details.primaryVelocity ?? 0.0) / screenHeight;
    
    if (velocity > 1.5 || velocity < -1.5) {
      // Create a tighter spring simulation for a faster fling
      final spring = SpringDescription(
        mass: 1.0,
        stiffness: 400.0,
        damping: 30.0,
      );
      final simulation = SpringSimulation(
        spring,
        _controller.value,
        velocity > 0 ? 1.0 : 0.0,
        velocity,
      );
      _controller.animateWith(simulation);
    } else {
      if (_controller.value > 0.5) {
        _controller.animateTo(1.0, curve: Curves.easeOutCubic, duration: AppDurations.fast);
      } else {
        _controller.animateTo(0.0, curve: Curves.easeOutCubic, duration: AppDurations.fast);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  List<Song>? _optimisticQueue;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_controller.value > 0.0) {
          _controller.animateTo(0.0, curve: Curves.easeOutCubic, duration: AppDurations.fast);
          if (_isQueueMode) {
            setState(() {
              _isQueueMode = false;
              _queueController.reverse();
            });
          }
          return;
        }

        if (context.canPop()) {
          context.pop();
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          AppSnackBar.show(context, 'Press back again to exit');
        } else {
          SystemNavigator.pop();
        }
      },
      child: BlocConsumer<PlayerBloc, PlayerUiState>(
        listenWhen: (prev, curr) => prev.queue != curr.queue || prev.currentIndex != curr.currentIndex,
        listener: (context, state) {
          _optimisticQueue = null;
        },
        builder: (context, state) {
          final song = state.currentSong;
          final hasSong = song != null;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            
            final safeAreaBottom = MediaQuery.of(context).padding.bottom;
            
            return AnimatedBuilder(
              animation: Listenable.merge([_controller, widget.shrinkProgress]),
              builder: (context, child) {
                // Apply curve to morphing layout but NOT to the drag itself to keep it strictly under the finger
                final curvedValue = _controller.value;
                
                final shrinkVal = widget.shrinkProgress.value;
                
                final minLeftMargin = 16.0 + 66.0 + 16.0; // nav margin + min nav width + gap
                final defaultMargin = 16.0; // Matches nav bar margin
                
                final currentLeftMargin = (defaultMargin + (minLeftMargin - defaultMargin) * shrinkVal) * (1 - curvedValue);
                final currentRightMargin = defaultMargin * (1 - curvedValue);
                
                final baseBottomMargin = (safeAreaBottom > 20 ? 16.0 : safeAreaBottom + 4.0);
                final bottomWhenNotShrunk = baseBottomMargin + 66.0 + 8.0; 
                final bottomWhenShrunk = baseBottomMargin;
                final currentBottom = bottomWhenShrunk + (bottomWhenNotShrunk - bottomWhenShrunk) * (1 - shrinkVal);
                
                final playerBottomPos = currentBottom * (1 - curvedValue);
                final playerHeight = _miniPlayerHeight + curvedValue * (screenHeight - _miniPlayerHeight);
                
                return Stack(
                  children: [
                    if (hasSong)
                      Positioned(
                        left: currentLeftMargin,
                        right: currentRightMargin,
                        bottom: playerBottomPos,
                        height: playerHeight,
                        child: GestureDetector(
                          onVerticalDragUpdate: _handleDragUpdate,
                          onVerticalDragEnd: _handleDragEnd,
                          onTap: () {
                            if (_controller.value < 0.1) {
                              _controller.animateTo(1.0, curve: Curves.easeOutCubic, duration: AppDurations.fast);
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30 + 6 * curvedValue),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20 * (1 - curvedValue), sigmaY: 20 * (1 - curvedValue)),
                              child: Container(
                                decoration: BoxDecoration(
                                  // Morph from frosted glass (nav bar style) to solid surface (expanded player style)
                                  color: Color.lerp(
                                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                                    Theme.of(context).colorScheme.surface,
                                    curvedValue,
                                  ),
                                  borderRadius: BorderRadius.circular(30 + 6 * curvedValue),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                    width: 0.5,
                                  ),
                                  // Drop shadow only when expanded
                                  boxShadow: curvedValue > 0 ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2 + 0.1 * curvedValue),
                                      blurRadius: 20 + 20 * curvedValue,
                                      spreadRadius: 2 * (1 - curvedValue),
                                      offset: const Offset(0, 8),
                                    ),
                                  ] : null,
                                ),
                                child: Stack(
                                  children: [
                                    if (curvedValue > 0)
                                      Positioned.fill(
                                        child: Transform.scale(
                                          scale: 1.15, // Scale up slightly to completely hide edge bleeding from the blur
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              if (song.artworkPath != null)
                                                Opacity(
                                                  opacity: curvedValue,
                                                  child: Image.file(
                                                    File(song.artworkPath!),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                                  ),
                                                ),
                                              BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 60.0 * curvedValue + 0.01, 
                                                  sigmaY: 60.0 * curvedValue + 0.01,
                                                  tileMode: TileMode.mirror,
                                                ),
                                                child: Container(
                                                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: 0.7 * curvedValue),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  
                                  if (curvedValue < 1.0)
                                    Opacity(
                                      opacity: (1 - curvedValue * 3).clamp(0.0, 1.0),
                                      child: _buildMiniPlayerUI(context, state, song),
                                    ),
                                    
                                  if (curvedValue > 0.0)
                                    Opacity(
                                      opacity: ((curvedValue - 0.3) * 1.5).clamp(0.0, 1.0),
                                      child: OverflowBox(
                                        maxHeight: screenHeight,
                                        alignment: Alignment.topCenter,
                                        child: _buildFullScreenUI(context, state, song, safeAreaBottom, screenHeight),
                                      ),
                                    ),
                                    
                                  _buildMorphingArtwork(song, curvedValue, screenWidth, screenHeight),
                                ],
                              ),
                            ),
                          ), // BackdropFilter
                        ), // ClipRRect
                      ), // GestureDetector
                    ), // Positioned
                  ], // Stack children
                );
              },
            );
          }
        );
      },
    ),
  );
}

  Widget _buildMiniPlayerUI(BuildContext context, PlayerUiState state, dynamic song) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 9.0, right: 12.0),
            child: Row(
              children: [
                const SizedBox(width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>().add(TogglePlayPause()),
                              icon: Icon(
                                state.status == PlayerStatus.playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                size: 28,
                              ),
                            ),
                            IconButton(
                              onPressed: state.hasNext ? () => context.read<PlayerBloc>().add(NextSong()) : null,
                              icon: Icon(
                                CupertinoIcons.forward_fill,
                                color: state.hasNext ? Theme.of(context).iconTheme.color : Theme.of(context).dividerColor,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: state.duration.inMilliseconds > 0 
                                  ? (state.position.inMilliseconds / state.duration.inMilliseconds).clamp(0.0, 1.0) 
                                  : 0.0,
                              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2), // Keep a small physical buffer
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Progress bar moved to under artist
      ],
    );
  }

  Widget _buildFullScreenUI(BuildContext context, PlayerUiState state, dynamic song, double safeAreaBottom, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: screenHeight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.normal,
                  child: _isQueueMode 
                      ? _buildQueueUI(context, state, song) 
                      : Center(
                          key: const ValueKey('poster'),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: const SizedBox.shrink(),
                          ),
                        ),
                ),
              ),
              
              if (!_isQueueMode) const SizedBox(height: 16),
              
              AnimatedSize(
                duration: AppDurations.normal,
                curve: Curves.easeOutCubic,
                child: _isQueueMode ? const SizedBox.shrink() : _buildTitleRow(context, state, song, isDark),
              ),
              
              const SizedBox(height: 4),
              
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  thumbColor: Theme.of(context).colorScheme.primary,
                ),
                child: Slider(
                  value: (_isDragging ? _dragPosition : state.position.inMilliseconds.toDouble())
                      .clamp(0.0, state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 1.0),
                  min: 0.0,
                  max: state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 1.0,
                  onChangeStart: (value) {
                    setState(() {
                      _isDragging = true;
                      _dragPosition = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _dragPosition = value;
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _isDragging = false;
                    });
                    context.read<PlayerBloc>().add(SeekToPosition(Duration(milliseconds: value.toInt())));
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_isDragging ? Duration(milliseconds: _dragPosition.toInt()) : state.position), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                    Text(_formatDuration(state.duration), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(CupertinoIcons.backward_end_fill),
                    color: state.hasPrevious ? null : Theme.of(context).dividerColor,
                    onPressed: state.hasPrevious ? () => context.read<PlayerBloc>().add(PreviousSong()) : null,
                  ),
                  IconButton(
                    iconSize: 64,
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icon(state.status == PlayerStatus.playing ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill),
                    onPressed: () => context.read<PlayerBloc>().add(TogglePlayPause()),
                  ),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(CupertinoIcons.forward_end_fill),
                    color: state.hasNext ? null : Theme.of(context).dividerColor,
                    onPressed: state.hasNext ? () => context.read<PlayerBloc>().add(NextSong()) : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.shuffle),
                        color: state.shuffleEnabled ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                        onPressed: () {
                        HapticFeedback.lightImpact();
                          context.read<PlayerBloc>().add(ToggleShuffle());
                        },
                      ),
                      IconButton(
                        icon: state.repeatMode == LoopMode.one
                            ? const Icon(CupertinoIcons.repeat_1)
                            : state.repeatMode == LoopMode.all
                                ? const Icon(CupertinoIcons.repeat)
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.repeat),
                                      Transform.rotate(
                                        angle: -0.785, // -45 degrees
                                        child: Container(
                                          width: 2,
                                          height: 22,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                        color: state.repeatMode != LoopMode.off
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodySmall?.color,
                        onPressed: () {
                        HapticFeedback.lightImpact();
                          context.read<PlayerBloc>().add(const ToggleRepeatMode());
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.list_bullet),
                    color: _isQueueMode ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                    onPressed: () {
                        HapticFeedback.lightImpact();
                      setState(() {
                        _isQueueMode = !_isQueueMode;
                        if (_isQueueMode) {
                          _queueController.forward();
                        } else {
                          _queueController.reverse();
                        }
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              _buildVolumeSlider(context, state),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(BuildContext context, PlayerUiState state) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            state.volume <= 0.01 ? CupertinoIcons.speaker : CupertinoIcons.speaker_1,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          onPressed: () => context.read<PlayerBloc>().add(const DecreaseVolume()),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: Theme.of(context).textTheme.bodyMedium?.color,
              inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              thumbColor: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            child: Slider(
              value: state.volume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                context.read<PlayerBloc>().add(SetVolume(value));
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            CupertinoIcons.speaker_3,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          onPressed: () => context.read<PlayerBloc>().add(const IncreaseVolume()),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, PlayerUiState state, dynamic song, bool isDark) {
    return Column(
      key: const ValueKey('title_row'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song?.title ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song?.artist ?? '',
                    style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodySmall?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (song != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(song.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
                    color: song.favorite ? AppColors.primary : null,
                    onPressed: () {
                        HapticFeedback.lightImpact();
                      context.read<PlayerBloc>().add(ToggleFavorite(song));
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(CupertinoIcons.ellipsis),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 8,
                    onSelected: (value) {
                      if (value == 'add_to_playlist') {
                        _showAddToPlaylistSheet(context, song);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_to_playlist',
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.music_note_list, size: 20),
                            SizedBox(width: 12),
                            Text('Add to Playlist'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
        if (song != null) ...[
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[800]! : Colors.grey[300]!).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    song.isLossless ? CupertinoIcons.waveform_path_badge_plus : CupertinoIcons.waveform_path,
                    size: 10,
                    color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    song.isLossless ? 'LOSSLESS' : 'HIGH QUALITY',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQueueUI(BuildContext context, PlayerUiState state, dynamic song) {
    final queue = _optimisticQueue ?? state.queue;
    return _QueueListWidget(
      queue: queue,
      currentIndex: state.currentIndex,
      song: song,
      onClose: () {
        setState(() {
          _isQueueMode = false;
          _queueController.reverse();
        });
      },
    );
  }

  Widget _buildMorphingArtwork(dynamic song, double curvedValue, double screenWidth, double screenHeight) {
    const double miniSize = 48.0;
    const double miniLeft = 9.0;
    const double miniTop = 9.0;
    const double miniRadius = 24.0;
    
    // Normal Full Screen Poster bounds
    // Removed duplicate declarations here
    
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    final double topOffset = safeAreaTop + 37.0;
    
    // Increased from 330 to 420 to account for new volume slider and padding
    final double bottomUIHeight = 420.0 + safeAreaBottom; 
    final double availableHeight = screenHeight - topOffset - bottomUIHeight;
    
    // Ensure the poster doesn't overflow its vertical constraints by taking the minimum
    final double maxPosterSize = availableHeight > 64.0 ? availableHeight - 64.0 : 0;
    final double normalFullSize = math.min(screenWidth - 120.0, maxPosterSize);
    final double normalFullLeft = (screenWidth - normalFullSize) / 2;
    
    final double normalFullTop = topOffset + (availableHeight / 2) - (normalFullSize / 2);
    final double normalFullRadius = 24.0;

    // Queue Mode Poster bounds
    final double queueFullSize = 60.0;
    final double queueFullLeft = 24.0;
    final double queueFullTop = topOffset;
    final double queueFullRadius = 8.0;

    return AnimatedBuilder(
      animation: _queueController,
      builder: (context, child) {
        final qVal = Curves.easeOutCubic.transform(_queueController.value);

        final fullSize = lerpDouble(normalFullSize, queueFullSize, qVal)!;
        final fullLeft = lerpDouble(normalFullLeft, queueFullLeft, qVal)!;
        final fullTop = lerpDouble(normalFullTop, queueFullTop, qVal)!;
        final fullRadius = lerpDouble(normalFullRadius, queueFullRadius, qVal)!;

        final currentSize = miniSize + (fullSize - miniSize) * curvedValue;
        final currentLeft = miniLeft + (fullLeft - miniLeft) * curvedValue;
        final currentTop = miniTop + (fullTop - miniTop) * curvedValue;
        final currentRadius = miniRadius + (fullRadius - miniRadius) * curvedValue;

        return Positioned(
          left: currentLeft,
          top: currentTop,
          width: currentSize,
          height: currentSize,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(currentRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3 * curvedValue),
                    blurRadius: 24 * curvedValue,
                    offset: Offset(0, 12 * curvedValue),
                  )
                ],
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(currentRadius),
                child: song.artworkPath != null
                    ? Image.file(
                        File(song.artworkPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(CupertinoIcons.music_note, color: Colors.white, size: 24 + 56 * curvedValue),
                      )
                    : Icon(CupertinoIcons.music_note, color: Colors.white, size: 24 + 56 * curvedValue),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StreamBuilder<List<Playlist>>(
          stream: sl<LibraryRepository>().watchPlaylists(),
          builder: (context, snapshot) {
            final playlists = snapshot.data ?? [];
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Add to Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (playlists.isEmpty)
                        const Padding(
                          padding: AppPadding.allXxl,
                          child: Text('No playlists created yet.'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];
                              final isAlreadyAdded = playlist.songIds.contains(song.id);
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isAlreadyAdded 
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                                    borderRadius: AppRadius.circularSm,
                                  ),
                                  child: Icon(
                                    isAlreadyAdded ? CupertinoIcons.checkmark_alt : CupertinoIcons.music_note_list,
                                    color: isAlreadyAdded ? Theme.of(context).colorScheme.primary : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${playlist.songIds.length} songs',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                                trailing: Icon(
                                  isAlreadyAdded 
                                      ? CupertinoIcons.checkmark_circle_fill 
                                      : CupertinoIcons.circle,
                                  color: isAlreadyAdded 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.white30,
                                ),
                                onTap: () {
                                  if (isAlreadyAdded) {
                                    context.read<LibraryBloc>().add(
                                          RemoveSongFromPlaylist(playlist, song),
                                        );
                                  } else {
                                    context.read<LibraryBloc>().add(
                                          AddSongToPlaylist(playlist, song),
                                        );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _QueueListWidget extends StatefulWidget {
  final List<Song> queue;
  final int currentIndex;
  final dynamic song;
  final VoidCallback onClose;

  const _QueueListWidget({
    Key? key,
    required this.queue,
    required this.currentIndex,
    required this.song,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_QueueListWidget> createState() => _QueueListWidgetState();
}

class _QueueListWidgetState extends State<_QueueListWidget> {
  late ScrollController _scrollController;
  bool _pastRevealed = false;
  bool _bottomReached = false;
  List<Song>? _optimisticQueue;

  @override
  void initState() {
    super.initState();
    // Calculate initial offset:
    // Past songs: widget.currentIndex * 64.0 (assuming 64 is item height)
    // Divider: 25.0 (if currentIndex > 0)
    double offset = 0.0;
    if (widget.currentIndex > 0) {
      offset = (widget.currentIndex * 64.0) + 25.0;
    }
    _scrollController = ScrollController(initialScrollOffset: offset);
  }

  @override
  void didUpdateWidget(_QueueListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      double targetOffset = 0.0;
      if (widget.currentIndex > 0) {
        targetOffset = (widget.currentIndex * 64.0) + 25.0;
      }
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetOffset,
          duration: AppDurations.slow,
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = _optimisticQueue ?? widget.queue;
    
    return Column(
      key: const ValueKey('queue_ui'),
      children: [
        SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 84),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.song?.title ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.song?.artist ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Playing Next',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<PlayerBloc>().add(const ClearQueue());
              },
              child: Text('Clear Queue', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
        
        Expanded(
          child: queue.length <= 1
              ? const Center(
                  child: Text('Empty Queue',
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.05, 0.90, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo is ScrollUpdateNotification) {
                        if (widget.currentIndex > 0) {
                          double threshold = (widget.currentIndex * 64.0) + 25.0 - 10.0;
                          if (scrollInfo.metrics.pixels < threshold && !_pastRevealed) {
                            HapticFeedback.selectionClick();
                            _pastRevealed = true;
                          } else if (scrollInfo.metrics.pixels > threshold + 20) {
                            _pastRevealed = false;
                          }
                        }
                        
                        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent && scrollInfo.metrics.maxScrollExtent > 0) {
                          if (!_bottomReached) {
                            HapticFeedback.selectionClick();
                            _bottomReached = true;
                          }
                        } else if (scrollInfo.metrics.pixels < scrollInfo.metrics.maxScrollExtent - 20) {
                          _bottomReached = false;
                        }
                      }
                      return false;
                    },
                    child: ReorderableListView(
                      onReorderStart: (index) => HapticFeedback.selectionClick(),
                      onReorderEnd: (index) => HapticFeedback.lightImpact(),
                      scrollController: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        // Map visual indices to actual queue indices
                        int mapVisualToQueue(int visIndex) {
                          if (widget.currentIndex == 0) {
                            // No past songs, no divider
                            return visIndex + 1; // Everything is after current song
                          } else {
                            if (visIndex < widget.currentIndex) return visIndex; // Past song
                            if (visIndex == widget.currentIndex) return -1; // Divider
                            return visIndex; // Future song (visIndex 1 is queue[1], wait...)
                            // If C=2. Past: 0,1. Divider: 2. Future: 3,4. Queue: 0,1,2(curr),3,4
                            // visIndex 0 -> queue 0
                            // visIndex 1 -> queue 1
                            // visIndex 2 -> Divider
                            // visIndex 3 -> queue 3
                          }
                        }
                        
                        if (oldIndex < newIndex) newIndex -= 1;
                        
                        int realOld = mapVisualToQueue(oldIndex);
                        int realNew = mapVisualToQueue(newIndex);
                        
                        if (realOld == -1 || realNew == -1) return; // Can't reorder divider
                        
                        setState(() {
                          _optimisticQueue = List.from(widget.queue);
                          final item = _optimisticQueue!.removeAt(realOld);
                          
                          // After removing from realOld, we need to adjust realNew if it was after realOld
                          int adjustedNew = realNew;
                          if (realOld < realNew) {
                            adjustedNew -= 1;
                          }
                          _optimisticQueue!.insert(adjustedNew, item);
                        });
                        context.read<PlayerBloc>().add(ReorderQueue(realOld, realNew));
                      },
                      children: _buildListChildren(queue),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildListChildren(List<Song> queue) {
    List<Widget> children = [];
    
    for (int i = 0; i < queue.length; i++) {
      if (i == widget.currentIndex) {
        if (widget.currentIndex > 0) {
          children.add(
            Container(
              key: const ValueKey('divider'),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Row(
                children: List.generate(40, (index) {
                  return Expanded(
                    child: Container(
                      color: index % 2 == 0 ? Colors.grey.withValues(alpha: 0.3) : Colors.transparent,
                      height: 1,
                    ),
                  );
                }),
              ),
            )
          );
        }
        continue; // Skip current song
      }
      
      final qSong = queue[i];
      final isPast = i < widget.currentIndex;
      
      children.add(
        InkWell(
          key: ValueKey(qSong.id + '_$i'),
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<PlayerBloc>().add(PlaySong(song: qSong, queue: queue));
          },
          child: Opacity(
            opacity: isPast ? 0.4 : 1.0,
            child: SizedBox(
              height: 64, // explicitly height to match our offset calculation
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    if (!isPast)
                      ReorderableDragStartListener(
                        index: children.length, // use current length as visual index
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(CupertinoIcons.bars, color: Colors.white38),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: qSong.artworkPath != null
                            ? Image.file(
                                File(qSong.artworkPath!),
                                fit: BoxFit.cover,
                              )
                            : const Icon(CupertinoIcons.music_note, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            qSong.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            qSong.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      );
    }
    
    return children;
  }
}
