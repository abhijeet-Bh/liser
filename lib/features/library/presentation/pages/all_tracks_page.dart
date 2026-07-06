import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class AllTracksPage extends StatelessWidget {
  const AllTracksPage({super.key});

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
        title: const Text('All Tracks', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
            tooltip: 'Clear Library',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Clear Library', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to remove all songs and playlists? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<LibraryBloc>().add(ClearLibrary());
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                      padding: const EdgeInsets.only(top: 8, bottom: 150),
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
                                  Stack(
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
                                      if (song.isLossless)
                                        Positioned(
                                          bottom: -2,
                                          right: -2,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(CupertinoIcons.star_fill, color: Color(0xFF10B981), size: 12),
                                          ),
                                        ),
                                    ],
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

                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      song.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: song.favorite ? Colors.red : Theme.of(context).textTheme.bodySmall?.color,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context.read<LibraryBloc>().add(LibraryToggleFavorite(song));
                                    },
                                  ),
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
