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
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';

import 'package:liser/core/utils/app_toast.dart';

class AllTracksPage extends StatefulWidget {
  final String? artistFilter;
  const AllTracksPage({super.key, this.artistFilter});

  @override
  State<AllTracksPage> createState() => _AllTracksPageState();
}

class _AllTracksPageState extends State<AllTracksPage> {
  String _searchQuery = '';

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

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StreamBuilder<List<Playlist>>(
          stream: sl<LibraryRepository>().watchPlaylists(),
          builder: (context, snapshot) {
            final playlists = snapshot.data ?? [];
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Add to Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (playlists.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No playlists created yet.'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];
                              final isAlreadyAdded = playlist.songIds.contains(song.id);
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isAlreadyAdded 
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isAlreadyAdded ? CupertinoIcons.checkmark_alt : CupertinoIcons.music_note_list,
                                    color: isAlreadyAdded ? Theme.of(context).colorScheme.primary : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${playlist.songIds.length} songs',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                                trailing: Icon(
                                  isAlreadyAdded 
                                      ? CupertinoIcons.checkmark_circle_fill 
                                      : CupertinoIcons.circle,
                                  color: isAlreadyAdded 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.white30,
                                ),
                                onTap: () {
                                  if (isAlreadyAdded) {
                                    context.read<LibraryBloc>().add(
                                          RemoveSongFromPlaylist(playlist, song),
                                        );
                                  } else {
                                    context.read<LibraryBloc>().add(
                                          AddSongToPlaylist(playlist, song),
                                        );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            children: [
              Text(widget.artistFilter ?? 'All Tracks', style: const TextStyle(fontWeight: FontWeight.w700)),
              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  final filteredSongs = widget.artistFilter != null ? state.songs.where((s) => s.artist == widget.artistFilter).toList() : state.songs;
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CupertinoSearchTextField(
                placeholder: 'Search songs or artists...',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                itemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, libraryState) {
                switch (libraryState.status) {
                  case LibraryStatus.initial:
                  case LibraryStatus.loading:
                    return const Center(child: CircularProgressIndicator());

                  case LibraryStatus.failure:
                    return Center(child: Text(libraryState.error ?? 'Unknown error'));

                  case LibraryStatus.loaded:
                    final baseSongs = widget.artistFilter != null ? libraryState.songs.where((s) => s.artist == widget.artistFilter).toList() : libraryState.songs;
                    final filteredSongs = _searchQuery.isEmpty 
                      ? baseSongs 
                      : baseSongs.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()) || s.artist.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                    return CustomScrollView(
                      slivers: [
                        if (filteredSongs.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.music_note_list, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text('No songs found', style: Theme.of(context).textTheme.titleLarge),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 8, bottom: 150),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index.isOdd) {
                                    return const Divider(
                                      height: 1, 
                                      thickness: 1, 
                                      indent: 84, // Align with text (16 padding + 48 image + 16 spacing = 80 + 4)
                                      endIndent: 24,
                                      color: Colors.white10
                                    );
                                  }
                                  
                                  final songIndex = index ~/ 2;
                                  final song = filteredSongs[songIndex];

                                  return Slidable(
                                    key: ValueKey(song.id),
                                    startActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            context.read<PlayerBloc>().add(AddSongToEnd(song));
                                            AppToast.show(context, '${song.title} added to queue');
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
                                          onPressed: (slidableContext) async {
                                            final bloc = context.read<LibraryBloc>();
                                            bloc.add(RemoveSong(song));
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
                                                } else if (value == 'add_to_last') {
                                                  context.read<PlayerBloc>().add(AddSongToEnd(song));
                                                } else if (value == 'add_to_playlist') {
                                                  _showAddToPlaylistSheet(context, song);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'play_next',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.arrow_right_to_line, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Play Next'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'add_to_last',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.text_append, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Add to Last'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'add_to_playlist',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.music_note_list, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Add to Playlist'),
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
                                childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,
                              ),
                            ),
                          ),
                      ],
                    );
                }
                return const SizedBox.shrink();
              },
          ),
        ),
      ),
    );
  }
}
