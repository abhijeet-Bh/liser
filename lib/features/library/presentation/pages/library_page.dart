import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/widgets/app_scaffold.dart';

import 'package:liser/features/library/data/models/song.dart';
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Library')),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, libraryState) {
          switch (libraryState.status) {
            case LibraryStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case LibraryStatus.failure:
              return Center(child: Text(libraryState.error ?? 'Unknown error'));

            case LibraryStatus.loaded:
              if (libraryState.songs.isEmpty) {
                return const Center(child: Text('No songs found'));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          '${libraryState.songs.length} Songs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: libraryState.songs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final Song song = libraryState.songs[index];

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              song.title.isEmpty
                                  ? '?'
                                  : song.title[0].toUpperCase(),
                            ),
                          ),

                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          trailing:
                              song.isLossless
                                  ? const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.orange,
                                  )
                                  : null,

                          onTap: () {
                            context.read<PlayerBloc>().add(
                              PlaySong(song: song, queue: libraryState.songs),
                            );
                          },
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
