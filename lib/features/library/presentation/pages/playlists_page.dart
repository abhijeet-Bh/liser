import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:go_router/go_router.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Playlists', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              if (state.status == LibraryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final favorites = state.songs.where((s) => s.favorite).toList();
              final playlists = state.playlists;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8).copyWith(bottom: 150),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFavoritesCard(context, favorites),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Playlists', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        IconButton(
                          icon: Icon(CupertinoIcons.add_circled, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            _showCreatePlaylistDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (playlists.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No playlists yet. Create one above!', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...playlists.map((playlist) => _buildPlaylistCard(context, playlist, state.songs)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesCard(BuildContext context, List<Song> favorites) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push('/library/playlists/favorites');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Favorites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('${favorites.length} Tracks', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (favorites.isNotEmpty) {
                  context.read<PlayerBloc>().add(PlaySong(song: favorites.first, queue: favorites));
                }
              },
              child: const Icon(CupertinoIcons.play_circle_fill, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(BuildContext context, Playlist playlist, List<Song> allSongs) {
    final playlistSongs = allSongs.where((s) => playlist.songIds.contains(s.id)).toList();

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMiniCollage(playlist, playlistSongs, context),
            ),
          ),
          title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Text('${playlistSongs.length} Tracks', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.red),
            onPressed: () {
              context.read<LibraryBloc>().add(DeletePlaylist(playlist));
            },
          ),
          onTap: () {
            context.push('/library/playlists/${playlist.id}');
          },
        ),
        const Divider(height: 1, thickness: 1, indent: 96, endIndent: 24, color: Colors.white10),
      ],
    );
  }

  Widget _buildMiniCollage(Playlist playlist, List<Song> playlistSongs, BuildContext context) {
    if (playlist.coverPath != null && File(playlist.coverPath!).existsSync()) {
      return Image.file(File(playlist.coverPath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    if (playlistSongs.isEmpty) {
      return Icon(CupertinoIcons.music_albums, color: Theme.of(context).colorScheme.primary);
    }

    final artworks = playlistSongs
        .where((s) => s.artworkPath != null)
        .map((s) => s.artworkPath!)
        .toSet()
        .take(4)
        .toList();

    if (artworks.isEmpty) {
      return Icon(CupertinoIcons.music_albums, color: Theme.of(context).colorScheme.primary);
    }

    if (artworks.length == 1) {
      return Image.file(File(artworks[0]), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    if (artworks.length == 2 || artworks.length == 3) {
      return Row(
        children: [
          Expanded(child: Image.file(File(artworks[0]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
          Expanded(child: Image.file(File(artworks[1]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(artworks[0]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
              Expanded(child: Image.file(File(artworks[1]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(artworks[2]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
              Expanded(child: Image.file(File(artworks[3]), fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Playlist Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<LibraryBloc>().add(CreatePlaylist(name));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
