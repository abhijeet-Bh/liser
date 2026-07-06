import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final songs = state.songs;
              final Map<String, List<Song>> albumsMap = {};
              
              for (final song in songs) {
                if (song.album.isNotEmpty) {
                  albumsMap.putIfAbsent(song.album, () => []).add(song);
                }
              }

              final albums = albumsMap.keys.toList()..sort();

              return ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 150),
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.music_note_list, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: const Text('All Tracks', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                    onTap: () {
                      context.push('/library/all');
                    },
                  ),
                  const Divider(height: 1, thickness: 1, indent: 84, endIndent: 24, color: Colors.white10),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.music_albums, color: Theme.of(context).colorScheme.secondary),
                    ),
                    title: const Text('Playlists', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                    onTap: () {
                      context.push('/library/playlists');
                    },
                  ),
                  const SizedBox(height: 24),
                  if (albums.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('Albums', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    ),
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Adjust for image + text
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final albumName = albums[index];
                        final albumSongs = albumsMap[albumName]!;
                        final artworkPath = albumSongs.firstWhere((s) => s.artworkPath != null, orElse: () => albumSongs.first).artworkPath;
                        return _buildAlbumCard(context, albumName, artworkPath);
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, String albumName, String? artworkPath) {
    return GestureDetector(
      onTap: () {
        context.push('/library/playlists/album_$albumName');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: artworkPath != null && File(artworkPath).existsSync()
                    ? Image.file(
                        File(artworkPath),
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.music_albums,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            albumName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
