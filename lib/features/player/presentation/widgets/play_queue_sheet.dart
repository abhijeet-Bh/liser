import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class PlayQueueSheet extends StatelessWidget {
  const PlayQueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
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
          const Text('Up Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<PlayerBloc, PlayerUiState>(
              builder: (context, state) {
                final queue = state.queue;
                final currentIndex = state.currentIndex;

                if (queue.isEmpty) {
                  return const Center(child: Text('Queue is empty'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isPlaying = index == currentIndex;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: isPlaying ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          child: song.artworkPath != null
                              ? Image.file(
                                  File(song.artworkPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.music_note),
                                )
                              : const Icon(CupertinoIcons.music_note),
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                          color: isPlaying ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8) : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      trailing: isPlaying
                          ? Icon(CupertinoIcons.waveform, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        context.read<PlayerBloc>().add(PlaySong(song: song, queue: queue));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
