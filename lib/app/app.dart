import 'package:flutter/material.dart';
import 'package:liser/app/router/app_router.dart';
import 'package:liser/app/theme/app_theme.dart' as theme;

class LiserApp extends StatelessWidget {
  const LiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Liser',
      debugShowCheckedModeBanner: false,
      theme: theme.AppTheme.light,
      darkTheme: theme.AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
