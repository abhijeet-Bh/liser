import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/features/player/presentation/widgets/play_queue_sheet.dart';

class FullScreenPlayer extends StatelessWidget {
  const FullScreenPlayer({super.key});

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
        if (song == null) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Stack(
              children: [
                // Background blurred artwork
                if (song.artworkPath != null)
                  Positioned.fill(
                    child: Image.file(
                      File(song.artworkPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                // Frosted glass overlay
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                    child: Container(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                    ),
                  ),
                ),
                
                // Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        
                        // Artwork
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Hero(
                                tag: 'artwork_${song.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      )
                                    ],
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryLight],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: song.artworkPath != null
                                        ? Image.file(
                                            File(song.artworkPath!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.music_note, color: Colors.white, size: 80),
                                          )
                                        : const Icon(CupertinoIcons.music_note, color: Colors.white, size: 80),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Title & Artist
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song.artist,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodySmall?.color),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
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
                            IconButton(
                              icon: Icon(song.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
                              color: song.favorite ? AppColors.primary : null,
                              onPressed: () {
                                context.read<PlayerBloc>().add(ToggleFavorite(song));
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Progress Bar
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
                        
                        // Time Labels
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
                        
                        const SizedBox(height: 24),
                        
                        // Playback Controls
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
                        
                        const SizedBox(height: 24),

                        // Extra Controls (Queue)
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
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (modalContext) => BlocProvider.value(
                                    value: context.read<PlayerBloc>(),
                                    child: const FractionallySizedBox(
                                      heightFactor: 0.7,
                                      child: PlayQueueSheet(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                      ],
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
