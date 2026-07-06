import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';

class ExpandablePlayer extends StatefulWidget {
  final Widget bottomNavigationBar;
  
  const ExpandablePlayer({
    super.key,
    required this.bottomNavigationBar,
  });

  @override
  State<ExpandablePlayer> createState() => _ExpandablePlayerState();
}

class _ExpandablePlayerState extends State<ExpandablePlayer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _queueController;
  final double _miniPlayerHeight = 66.0;
  bool _isQueueMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _queueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _queueController.dispose();
    super.dispose();
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
        _controller.animateTo(1.0, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 200));
      } else {
        _controller.animateTo(0.0, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 200));
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerUiState>(
      builder: (context, state) {
        final song = state.currentSong;
        final hasSong = song != null;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            
            final safeAreaBottom = MediaQuery.of(context).padding.bottom;
            final navBarHeight = 56.0 + safeAreaBottom; 
            
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Apply curve to morphing layout but NOT to the drag itself to keep it strictly under the finger
                final curvedValue = _controller.value;
                
                final navBarOffset = curvedValue * navBarHeight;
                
                final playerBottomPos = (1 - curvedValue) * navBarHeight;
                final playerHeight = _miniPlayerHeight + curvedValue * (screenHeight - _miniPlayerHeight);
                final playerMargin = (1 - curvedValue) * 8.0;
                
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Transform.translate(
                        offset: Offset(0, navBarOffset),
                        child: widget.bottomNavigationBar,
                      ),
                    ),
                    
                    if (hasSong)
                      Positioned(
                        left: playerMargin,
                        right: playerMargin,
                        bottom: playerBottomPos + (1 - curvedValue) * 12.0, // Increased gap
                        height: playerHeight,
                        child: GestureDetector(
                          onVerticalDragUpdate: _handleDragUpdate,
                          onVerticalDragEnd: _handleDragEnd,
                          onTap: () {
                            if (_controller.value < 0.1) {
                              _controller.animateTo(1.0, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 200));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface, // Solid color to stand out from blur
                              borderRadius: BorderRadius.circular(12 + 24 * curvedValue),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1 - (0.1 * curvedValue)),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2 + 0.1 * curvedValue),
                                  blurRadius: 20 + 20 * curvedValue,
                                  spreadRadius: 2 * (1 - curvedValue),
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12 + 24 * curvedValue),
                              child: Stack(
                                children: [
                                  if (curvedValue > 0) ...[
                                    if (song.artworkPath != null)
                                      Positioned.fill(
                                        child: Opacity(
                                          opacity: curvedValue,
                                          child: Image.file(
                                            File(song.artworkPath!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: curvedValue,
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                                          child: Container(
                                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  
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
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          }
        );
      },
    );
  }

  Widget _buildMiniPlayerUI(BuildContext context, PlayerUiState state, dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<PlayerBloc>().add(TogglePlayPause()),
            icon: Icon(
              state.status == PlayerStatus.playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
              color: Theme.of(context).iconTheme.color,
              size: 26,
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
                  duration: const Duration(milliseconds: 300),
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
              
              const SizedBox(height: 24),
              
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _isQueueMode ? const SizedBox.shrink() : _buildTitleRow(context, state, song, isDark),
              ),
              
              const SizedBox(height: 16),
              
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Theme.of(context).dividerColor,
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  value: state.position.inMilliseconds.toDouble().clamp(0.0, state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 0.0),
                  max: state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 1.0,
                  onChanged: (value) {
                    context.read<PlayerBloc>().add(SeekToPosition(Duration(milliseconds: value.toInt())));
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(state.position), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                    Text(_formatDuration(state.duration), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(CupertinoIcons.backward_fill),
                    color: state.hasPrevious ? null : Theme.of(context).dividerColor,
                    onPressed: state.hasPrevious ? () => context.read<PlayerBloc>().add(PreviousSong()) : null,
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: Icon(state.status == PlayerStatus.playing ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid),
                      onPressed: () => context.read<PlayerBloc>().add(TogglePlayPause()),
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(CupertinoIcons.forward_fill),
                    color: state.hasNext ? null : Theme.of(context).dividerColor,
                    onPressed: state.hasNext ? () => context.read<PlayerBloc>().add(NextSong()) : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.shuffle),
                    color: state.shuffleEnabled ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                    onPressed: () {
                      context.read<PlayerBloc>().add(ToggleShuffle());
                    },
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.list_bullet),
                    color: _isQueueMode ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                    onPressed: () {
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, PlayerUiState state, dynamic song, bool isDark) {
    return Row(
      key: const ValueKey('title_row'),
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
              const SizedBox(height: 8),
              if (song != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        song.isLossless ? CupertinoIcons.waveform_path_badge_plus : CupertinoIcons.waveform_path,
                        size: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        song.isLossless ? 'LOSSLESS' : 'HIGH QUALITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (song != null)
          IconButton(
            icon: Icon(song.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
            color: song.favorite ? AppColors.primary : null,
            onPressed: () {
              context.read<PlayerBloc>().add(ToggleFavorite(song));
            },
          ),
      ],
    );
  }

  Widget _buildQueueUI(BuildContext context, PlayerUiState state, dynamic song) {
    return Column(
      key: const ValueKey('queue_ui'),
      children: [
        SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 84), // Space for morphing artwork (60) + padding (24)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song?.title ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song?.artist ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Playing Next',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.read<PlayerBloc>().add(const ClearQueue()),
              child: Text('Clear Queue', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        
        Expanded(
          child: state.queue.length <= state.currentIndex + 1 
          ? const Center(
              child: Text(
                'No upcoming songs', 
                style: TextStyle(color: Colors.grey, fontSize: 16)
              )
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: state.queue.length - state.currentIndex - 1,
              onReorder: (oldIndex, newIndex) {
                final baseIndex = state.currentIndex + 1;
                context.read<PlayerBloc>().add(ReorderQueue(baseIndex + oldIndex, baseIndex + newIndex));
              },
              itemBuilder: (context, index) {
                final songIndex = state.currentIndex + 1 + index;
                final qSong = state.queue[songIndex];
                
                return InkWell(
                  key: ValueKey(qSong.id + index.toString()),
                  onTap: () {
                    // Play this song? The queue logic usually just jumps to it or plays it.
                    // Let's just play it from the queue context if they tap it.
                    context.read<PlayerBloc>().add(PlaySong(song: qSong, queue: state.queue));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(CupertinoIcons.bars, color: Colors.white38),
                          ),
                        ),
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
                );
              },
            ),
        ),
      ],
    );
  }

  Widget _buildMorphingArtwork(dynamic song, double curvedValue, double screenWidth, double screenHeight) {
    const double miniSize = 50.0;
    const double miniLeft = 8.0;
    const double miniTop = 8.0;
    const double miniRadius = 8.0;
    
    // Normal Full Screen Poster bounds
    final double normalFullSize = screenWidth - 120.0;
    final double normalFullLeft = 60.0;
    
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    final double topOffset = safeAreaTop + 37.0;
    final double bottomUIHeight = 330.0 + safeAreaBottom;
    final double availableHeight = screenHeight - topOffset - bottomUIHeight;
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
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
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
}
