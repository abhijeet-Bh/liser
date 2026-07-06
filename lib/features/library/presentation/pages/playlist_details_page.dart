import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailsPage({super.key, required this.playlistId});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  bool _isEditing = false;

  Future<void> _pickCover(BuildContext context, Playlist playlist) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<LibraryBloc>().add(SetPlaylistCover(playlist, result.files.single.path!));
      }
    }
  }

  Widget _buildDynamicCollage(List<Song> songs, double size) {
    if (songs.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey.withValues(alpha: 0.2),
        child: const Icon(CupertinoIcons.music_albums, size: 64, color: Colors.white54),
      );
    }

    // Get up to 4 distinct artworks
    final artworks = songs
        .where((s) => s.artworkPath != null)
        .map((s) => s.artworkPath!)
        .toSet()
        .take(4)
        .toList();

    if (artworks.isEmpty) {
       return Container(
        width: size,
        height: size,
        color: Colors.grey.withValues(alpha: 0.2),
        child: const Icon(CupertinoIcons.music_note_list, size: 64, color: Colors.white54),
      );
    }

    if (artworks.length == 1) {
      return Image.file(File(artworks[0]), width: size, height: size, fit: BoxFit.cover);
    }

    if (artworks.length == 2 || artworks.length == 3) {
      return Row(
        children: [
          Expanded(child: Image.file(File(artworks[0]), height: size, fit: BoxFit.cover)),
          Expanded(child: Image.file(File(artworks[1]), height: size, fit: BoxFit.cover)),
        ],
      );
    }

    // 4 artworks
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(artworks[0]), fit: BoxFit.cover)),
              Expanded(child: Image.file(File(artworks[1]), fit: BoxFit.cover)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(artworks[2]), fit: BoxFit.cover)),
              Expanded(child: Image.file(File(artworks[3]), fit: BoxFit.cover)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        Playlist? playlist;
        List<Song> playlistSongs = [];
        final isFavorites = widget.playlistId == 'favorites';

        if (isFavorites) {
          playlistSongs = state.songs.where((s) => s.favorite).toList();
        } else {
          final playlistIndex = state.playlists.indexWhere((p) => p.id == widget.playlistId);
          if (playlistIndex == -1) {
            return const Scaffold(body: Center(child: Text('Playlist not found')));
          }
          playlist = state.playlists[playlistIndex];
          for (final id in playlist.songIds) {
            try {
              playlistSongs.add(state.songs.firstWhere((s) => s.id == id));
            } catch (_) {}
          }
        }

        return Scaffold(
          body: FrostedBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(CupertinoIcons.back),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      isFavorites ? 'Favorites' : playlist!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    background: GestureDetector(
                      onTap: isFavorites ? null : () => _pickCover(context, playlist!),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          (!isFavorites && playlist!.coverPath != null && File(playlist.coverPath!).existsSync())
                              ? Image.file(File(playlist.coverPath!), fit: BoxFit.cover)
                              : _buildDynamicCollage(playlistSongs, MediaQuery.of(context).size.width),
                          // Dark gradient overlay to make title and icons visible
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          if (!isFavorites)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      children: [
                        Text(
                          '${playlistSongs.length} Tracks',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: playlistSongs.isEmpty ? null : () {
                                final shuffled = List<Song>.from(playlistSongs)..shuffle();
                                context.read<PlayerBloc>().add(PlaySong(song: shuffled.first, queue: shuffled));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                                elevation: 0,
                              ),
                              child: const Icon(CupertinoIcons.shuffle, size: 24),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: playlistSongs.isEmpty ? null : () {
                                context.read<PlayerBloc>().add(PlaySong(song: playlistSongs.first, queue: playlistSongs));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 8,
                              ),
                              icon: const Icon(CupertinoIcons.play_fill, size: 28),
                              label: const Text('Play', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            if (!isFavorites)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isEditing 
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
                                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  foregroundColor: _isEditing ? Colors.white : Colors.white38,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(16),
                                  elevation: 0,
                                ),
                                child: Icon(
                                  _isEditing ? CupertinoIcons.check_mark : CupertinoIcons.slider_horizontal_3,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: SliverReorderableList(
                    itemCount: playlistSongs.length,
                    onReorder: (oldIndex, newIndex) {
                      if (!isFavorites) {
                        context.read<LibraryBloc>().add(ReorderPlaylistSongs(playlist!, oldIndex, newIndex));
                      }
                    },
                    itemBuilder: (context, index) {
                      final song = playlistSongs[index];
                      return Slidable(
                        key: ValueKey(song.id + index.toString()),
                        endActionPane: isFavorites ? null : ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                context.read<LibraryBloc>().add(RemoveSongFromPlaylist(playlist!, song));
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: CupertinoIcons.trash,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            context.read<PlayerBloc>().add(PlaySong(song: song, queue: playlistSongs));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Row(
                              children: [
                                if (_isEditing)
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
                                    child: song.artworkPath != null
                                        ? Image.file(File(song.artworkPath!), fit: BoxFit.cover)
                                        : const Icon(CupertinoIcons.music_note, color: Colors.grey),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 150),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
