import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:liser/app/app.dart';
import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/data/services/audio_player_service.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/core/services/native_volume_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.liser.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await setupDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppBloc()..add(AppStarted()),
        ),
        BlocProvider(
          create:
              (_) =>
                  LibraryBloc(
                    repository: sl<LibraryRepository>(),
                    syncService: sl(),
                  )
                    ..add(LoadLibrary()),
        ),
        BlocProvider(
          create: (_) => PlayerBloc(
            playerService: sl<AudioPlayerService>(),
            volumeService: sl<NativeVolumeService>(),
          ),
        ),
      ],
      child: const LiserApp(),
    ),
  );
}
