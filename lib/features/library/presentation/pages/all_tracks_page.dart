import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AllTracksPage extends StatelessWidget {
  const AllTracksPage({super.key});

  Widget _buildFallbackIcon(BuildContext context, Song song) {
    if (song.title.isEmpty) return const Icon(CupertinoIcons.music_note, color: Colors.grey);
    return Center(
      child: Text(
        song.title[0].toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            const Text('All Tracks', style: TextStyle(fontWeight: FontWeight.w700)),
            BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state.status == LibraryStatus.loaded && state.songs.isNotEmpty) {
                  return Text(
                    '${state.songs.length} Tracks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
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
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<LibraryBloc, LibraryState>(
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
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 8, bottom: 150),
                            itemCount: libraryState.songs.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1, 
                              thickness: 1, 
                              indent: 84, // Align with text (16 padding + 48 image + 16 spacing = 80 + 4)
                              endIndent: 24,
                              color: Colors.white10
                            ),
                            itemBuilder: (context, index) {
                              final song = libraryState.songs[index];

                              return Slidable(
                                key: ValueKey(song.id),
                                startActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        context.read<PlayerBloc>().add(AddSongToEnd(song));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${song.title} added to queue', style: const TextStyle(fontWeight: FontWeight.w500)),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        );
                                      },
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      icon: CupertinoIcons.text_insert,
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        final delete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Song', style: TextStyle(fontWeight: FontWeight.bold)),
                                            content: Text('Are you sure you want to remove "${song.title}" from your library?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ) ?? false;

                                        if (delete) {
                                          if (context.mounted) {
                                            context.read<LibraryBloc>().add(RemoveSong(song));
                                          }
                                        }
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: CupertinoIcons.trash,
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    context.read<PlayerBloc>().add(
                                          PlaySong(song: song, queue: libraryState.songs),
                                        );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                                  child: const Icon(CupertinoIcons.star_fill, color: Color(0xFF10B981), size: 10),
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
                                            if (value == 'play_next') {
                                              context.read<PlayerBloc>().add(AddSongNext(song));
                                            } else if (value == 'play_last') {
                                              context.read<PlayerBloc>().add(AddSongToEnd(song));
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'play_next',
                                              child: Row(
                                                children: [
                                                  Icon(CupertinoIcons.text_append, size: 20),
                                                  SizedBox(width: 12),
                                                  Text('Play Next', style: TextStyle(fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'play_last',
                                              child: Row(
                                                children: [
                                                  Icon(CupertinoIcons.text_insert, size: 20),
                                                  SizedBox(width: 12),
                                                  Text('Play Last', style: TextStyle(fontWeight: FontWeight.w500)),
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
              }
        ),
      ),),
    );
  }
}
