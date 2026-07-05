import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

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

        return Material(
          elevation: 12,
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: () {
              context.push('/player');
            },
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    const SizedBox(width: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: Colors.grey.shade300,
                        child:
                            song.artworkPath != null
                                ? Image.network(
                                  song.artworkPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(Icons.music_note);
                                  },
                                )
                                : const Icon(Icons.music_note),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(TogglePlayPause());
                      },
                      icon: Icon(
                        state.status == PlayerStatus.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),

                    const SizedBox(width: 8),
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
