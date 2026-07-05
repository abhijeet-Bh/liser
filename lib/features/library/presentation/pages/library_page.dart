import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/widgets/app_scaffold.dart';

import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';

import 'package:liser/features/player/data/services/audio_player_service.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  LibraryBloc(repository: sl<LibraryRepository>())
                    ..add(LoadLibrary()),
        ),
        BlocProvider(
          create: (_) => PlayerBloc(playerService: sl<AudioPlayerService>()),
        ),
      ],
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  Widget _buildFallbackIcon(BuildContext context, song) {
    if (song.title.isEmpty) return const Icon(Icons.music_note);
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<LibraryBloc>().add(AddSongs());
        },
        child: const Icon(Icons.add_rounded),
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
                      const Icon(Icons.music_off, size: 64, color: Colors.grey),
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
                      padding: const EdgeInsets.only(top: 8, bottom: 100), // padding for miniplayer
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
                                    icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
                                    onSelected: (value) {
                                      if (value == 'remove') {
                                        context.read<LibraryBloc>().add(RemoveSong(song));
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Text('Remove from Library'),
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
