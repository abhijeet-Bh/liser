import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/features/player/presentation/bloc/player_bloc.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerUiState>(
      builder: (context, state) {
        final song = state.currentSong;

        if (song == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Nothing is playing")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Now Playing",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child:
                          song.artworkPath != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.file(
                                  File(song.artworkPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Icon(Icons.music_note, size: 150),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    song.artist,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),
                  Slider(
                    value: state.position.inMilliseconds.toDouble().clamp(
                      0,
                      state.duration.inMilliseconds == 0
                          ? 1
                          : state.duration.inMilliseconds.toDouble(),
                    ),
                    max:
                        state.duration.inMilliseconds == 0
                            ? 1
                            : state.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      context.read<PlayerBloc>().add(
                        SeekToPosition(Duration(milliseconds: value.toInt())),
                      );
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(state.position)),
                      Text(_formatDuration(state.duration)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 42,
                        onPressed: () {
                          context.read<PlayerBloc>().add(PreviousSong());
                        },
                        icon: const Icon(Icons.skip_previous),
                      ),

                      IconButton(
                        iconSize: 72,
                        onPressed: () {
                          context.read<PlayerBloc>().add(TogglePlayPause());
                        },
                        icon: Icon(
                          state.status == PlayerStatus.playing
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                      ),

                      IconButton(
                        iconSize: 42,
                        onPressed: () {
                          context.read<PlayerBloc>().add(NextSong());
                        },
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Favorite feature
                        },
                        icon: Icon(
                          song.favorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: song.favorite ? Colors.red : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Queue page
                        },
                        icon: const Icon(Icons.queue_music),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
