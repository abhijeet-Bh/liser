import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  Widget _buildFallbackIcon(BuildContext context, Song song) {
    if (song.title.isEmpty) return const Icon(CupertinoIcons.music_note);
    return Center(
      child: Text(
        song.title[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, libraryState) {
          switch (libraryState.status) {
            case LibraryStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case LibraryStatus.failure:
              return Center(child: Text(libraryState.error ?? 'Unknown error'));

            case LibraryStatus.loaded:
              if (libraryState.songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.music_note_list, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No songs found', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      '${libraryState.songs.length} Tracks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 150), // padding for miniplayer and full-width navbar
                      itemCount: libraryState.songs.length,
                      itemBuilder: (context, index) {
                        final song = libraryState.songs[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.read<PlayerBloc>().add(
                                    PlaySong(song: song, queue: libraryState.songs),
                                  );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                      child: song.artworkPath != null
                                          ? Image.file(
                                              File(song.artworkPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(context, song),
                                            )
                                          : _buildFallbackIcon(context, song),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          song.artist,
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
                                  if (song.isLossless)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        'LOSSLESS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: Icon(CupertinoIcons.ellipsis, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    color: Theme.of(context).colorScheme.surface,
                                    elevation: 8,
                                    onSelected: (value) {
                                      if (value == 'remove') {
                                        context.read<LibraryBloc>().add(RemoveSong(song));
                                      } else if (value == 'play_next') {
                                        // feature
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'play_next',
                                        child: Row(
                                          children: [
                                            Icon(CupertinoIcons.play_circle, size: 20),
                                            SizedBox(width: 12),
                                            Text('Play Next', style: TextStyle(fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
                                            SizedBox(width: 12),
                                            Text('Remove from Library', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );

            case LibraryStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
