import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              if (state.status == LibraryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.music_note_list, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('Your library is empty', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Go to Settings to import music.', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                );
              }

              final allSongs = List<Song>.from(state.songs);
              allSongs.shuffle();
              final suggestedSongs = allSongs.take(10).toList();

              final artistCounts = <String, int>{};
              for (final song in state.songs) {
                if (song.artist.isNotEmpty) {
                  artistCounts[song.artist] = (artistCounts[song.artist] ?? 0) + 1;
                }
              }
              final sortedArtists = artistCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
              final topArtists = sortedArtists.take(10).map((e) => e.key).toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 150),
                children: [
                  _buildSectionTitle(context, 'Suggested Songs'),
                  _buildSuggestedSongs(context, suggestedSongs),
                  const SizedBox(height: 32),
                  if (topArtists.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Top Artists'),
                    _buildTopArtists(context, topArtists),
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
    );
  }

  Widget _buildSuggestedSongs(BuildContext context, List<Song> songs) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () {
              context.read<PlayerBloc>().add(PlaySong(song: song, queue: songs));
            },
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: song.artworkPath != null
                        ? Image.file(
                            File(song.artworkPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _fallbackIcon(context),
                          )
                        : _fallbackIcon(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return Center(
      child: Icon(
        CupertinoIcons.music_note,
        size: 48,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildTopArtists(BuildContext context, List<String> artists) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.person_alt,
                    size: 40,
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 110,
                child: Text(
                  artist,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
