import 'package:flutter/material.dart';
import 'package:liser/app/router/app_router.dart';
import 'package:liser/app/theme/app_theme.dart' as theme;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/app/bloc/app_bloc.dart';

class LiserApp extends StatelessWidget {
  const LiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.system;
        if (state.settings != null) {
          if (state.settings!.themeMode == 1) {
            themeMode = ThemeMode.light;
          } else if (state.settings!.themeMode == 2) {
            themeMode = ThemeMode.dark;
          }
        }

        return MaterialApp.router(
          title: 'Liser',
          debugShowCheckedModeBanner: false,
          theme: theme.AppTheme.light,
          darkTheme: theme.AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
