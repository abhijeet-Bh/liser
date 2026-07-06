import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _lastUpdateCount = -1;
  List<Song> _suggestedSongs = [];
  List<Map<String, dynamic>> _mixes = [];
  List<String> _topArtists = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _lastUpdateCount = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'LISER',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        toolbarHeight: 80,
        actions: [
          BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) {
              final photoPath = appState.settings?.userPhotoPath;
              return GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    image: photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(photoPath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoPath == null
                      ? Icon(
                          CupertinoIcons.person_fill,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
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

              if (state.songs.isNotEmpty && state.updateCount != _lastUpdateCount) {
                final allSongs = List<Song>.from(state.songs);
                
                // Top Artists
                final artistCounts = <String, int>{};
                for (final song in allSongs) {
                  if (song.artist.isNotEmpty) {
                    artistCounts[song.artist] = (artistCounts[song.artist] ?? 0) + 1;
                  }
                }
                final sortedArtists = artistCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                _topArtists = sortedArtists.take(10).map((e) => e.key).toList();

                // Suggested Songs
                allSongs.shuffle();
                _suggestedSongs = allSongs.take(10).toList();
                
                // Mixes
                _mixes = [];
                
                // Most Played Mix
                final mostPlayedSongs = allSongs.where((s) => s.playCount > 0).toList()..sort((a, b) => b.playCount.compareTo(a.playCount));
                if (mostPlayedSongs.isNotEmpty) {
                  _mixes.add({
                    'name': 'Most Played',
                    'songs': mostPlayedSongs.take(20).toList(),
                  });
                }
                
                // Playlist Mixes
                List<Map<String, dynamic>> playlistMixes = [];
                for (final playlist in state.playlists) {
                  final playlistSongs = allSongs.where((s) => playlist.songIds.contains(s.id)).toList();
                  if (playlistSongs.isNotEmpty) {
                    playlistSongs.shuffle();
                    // Each mix should be about 15 songs
                    int numMixes = (playlistSongs.length / 15).ceil();
                    if (numMixes == 0) numMixes = 1;
                    
                    for (int i = 0; i < numMixes; i++) {
                      final chunk = playlistSongs.skip(i * 15).take(15).toList();
                      if (chunk.isNotEmpty) {
                        playlistMixes.add({
                          'name': '${playlist.name} Mix ${numMixes > 1 ? (i + 1).toString() : ''}'.trim(),
                          'songs': chunk,
                        });
                      }
                    }
                  }
                }
                
                playlistMixes.shuffle();
                for (final mix in playlistMixes) {
                  if (_mixes.length >= 6) break;
                  _mixes.add(mix);
                }
                
                // Fill remaining with random mixes if needed
                int randomMixCount = 1;
                while (_mixes.length < 6) {
                  allSongs.shuffle();
                  _mixes.add({
                    'name': 'Random Mix $randomMixCount',
                    'songs': allSongs.take(15).toList(),
                  });
                  randomMixCount++;
                }

                _lastUpdateCount = state.updateCount;
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 150),
                children: [
                  _buildSectionTitle(context, 'Liser Mixes'),
                  _buildMixesSection(context),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Suggested Songs'),
                  _buildSuggestedSongs(context, _suggestedSongs),
                  const SizedBox(height: 32),
                  if (_topArtists.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Top Artists'),
                    _buildTopArtists(context, _topArtists),
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMixesSection(BuildContext context) {
    if (_mixes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _mixes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final mixMap = _mixes[index];
          final String name = mixMap['name'];
          final List<Song> mix = mixMap['songs'];
          
          return GestureDetector(
            onTap: () {
              if (mix.isNotEmpty) {
                context.read<PlayerBloc>().add(PlaySong(song: mix.first, queue: mix));
              }
            },
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildMixCollage(mix, context),
                            Container(
                              color: Colors.black.withValues(alpha: 0.2), // Darken the collage slightly
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.play_fill,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMixCollage(List<Song> songs, BuildContext context) {
    final artworks = songs
        .where((s) => s.artworkPath != null)
        .map((s) => s.artworkPath!)
        .toSet()
        .take(4)
        .toList();

    if (artworks.isEmpty) {
      return Icon(CupertinoIcons.music_albums, color: Theme.of(context).colorScheme.primary, size: 40);
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
