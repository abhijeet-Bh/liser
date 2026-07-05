import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:liser/app/app.dart';
import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(
    BlocProvider(
      create: (_) => AppBloc()..add(AppStarted()),
      child: const LiserApp(),
    ),
  );
}
