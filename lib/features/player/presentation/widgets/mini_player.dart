import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/features/player/presentation/widgets/full_screen_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerUiState>(
      builder: (context, state) {
        final song = state.currentSong;

        if (song == null) {
          return const SizedBox.shrink();
        }
        
        final playerBloc = context.read<PlayerBloc>();

        return Container(
          height: 66,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: false,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BlocProvider.value(
                      value: playerBloc,
                      child: const FullScreenPlayer(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'artwork_${song.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryLight,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: song.artworkPath != null
                                    ? Image.file(
                                        File(song.artworkPath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(CupertinoIcons.music_note, color: Colors.white, size: 24);
                                        },
                                      )
                                    : const Icon(CupertinoIcons.music_note, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
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
                            onPressed: () {
                              context.read<PlayerBloc>().add(TogglePlayPause());
                            },
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
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Builder(
                        builder: (context) {
                          final duration = state.duration;
                          final position = state.position;
                          final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
                          return LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 2,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
