import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AllTracksPage extends StatelessWidget {
  final String? artistFilter;
  const AllTracksPage({super.key, this.artistFilter});

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

  void _showAddToPlaylistSheet(BuildContext context, Song song, List<Playlist> playlists) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            top: 16, 
            bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Add to Playlist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (playlists.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('No playlists available.', style: TextStyle(color: Theme.of(sheetContext).textTheme.bodySmall?.color)),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
                          minHeight: 150,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          final bool isAlreadyInPlaylist = playlist.songIds.contains(song.id);
                          
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isAlreadyInPlaylist 
                                    ? Colors.grey.withValues(alpha: 0.1) 
                                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                CupertinoIcons.music_note_list, 
                                color: isAlreadyInPlaylist ? Colors.grey : Theme.of(context).colorScheme.primary
                              ),
                            ),
                            title: Text(
                              playlist.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isAlreadyInPlaylist ? Colors.white38 : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '${playlist.songIds.length} songs',
                              style: TextStyle(
                                color: isAlreadyInPlaylist ? Colors.white38 : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                            trailing: isAlreadyInPlaylist 
                                ? const Icon(CupertinoIcons.checkmark_alt, color: Colors.white38)
                                : const Icon(CupertinoIcons.add_circled, color: Colors.white70),
                            enabled: !isAlreadyInPlaylist,
                            onTap: () {
                              if (!isAlreadyInPlaylist) {
                                context.read<LibraryBloc>().add(AddSongToPlaylist(playlist, song));
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to ${playlist.name}'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ), // closes Column
            ), // closes Material
          ), // closes BackdropFilter
        ), // closes ClipRRect
      ); // closes Container
    }, // closes builder
  ); // closes showModalBottomSheet
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
            Text(artistFilter ?? 'All Tracks', style: const TextStyle(fontWeight: FontWeight.w700)),
            BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                final filteredSongs = artistFilter != null ? state.songs.where((s) => s.artist == artistFilter).toList() : state.songs;
                if (state.status == LibraryStatus.loaded && filteredSongs.isNotEmpty) {
                  return Text(
                    '${filteredSongs.length} Tracks',
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
                    final filteredSongs = artistFilter != null ? libraryState.songs.where((s) => s.artist == artistFilter).toList() : libraryState.songs;
                    if (filteredSongs.isEmpty) {
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
                            itemCount: filteredSongs.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1, 
                              thickness: 1, 
                              indent: 84, // Align with text (16 padding + 48 image + 16 spacing = 80 + 4)
                              endIndent: 24,
                              color: Colors.white10
                            ),
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];

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
                                        final delete = await showGeneralDialog<bool>(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: 'Dismiss',
                                          transitionDuration: const Duration(milliseconds: 300),
                                          pageBuilder: (context, animation, secondaryAnimation) {
                                            return Center(
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 32),
                                                padding: const EdgeInsets.all(24),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  borderRadius: BorderRadius.circular(24),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.3),
                                                      blurRadius: 30,
                                                      offset: const Offset(0, 15),
                                                    ),
                                                  ],
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(20),
                                                        decoration: BoxDecoration(
                                                          color: Colors.redAccent.withValues(alpha: 0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(CupertinoIcons.trash, size: 56, color: Colors.redAccent),
                                                      ),
                                                      const SizedBox(height: 24),
                                                      const Text('Delete Song?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 12),
                                                      Text(
                                                        'Are you sure you want to remove "${song.title}" from your library?',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color, height: 1.4),
                                                      ),
                                                      const SizedBox(height: 32),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              style: TextButton.styleFrom(
                                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                              ),
                                                              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 16),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.redAccent,
                                                                foregroundColor: Colors.white,
                                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                elevation: 0,
                                                              ),
                                                              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                                          transitionBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                                                child: child,
                                              ),
                                            );
                                          },
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
                                          PlaySong(song: song, queue: filteredSongs),
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
                                            } else if (value == 'add_to_playlist') {
                                              _showAddToPlaylistSheet(context, song, libraryState.playlists);
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
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              value: 'add_to_playlist',
                                              child: Row(
                                                children: [
                                                  Icon(CupertinoIcons.music_note_list, size: 20),
                                                  SizedBox(width: 12),
                                                  Text('Add to Playlist', style: TextStyle(fontWeight: FontWeight.w500)),
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
