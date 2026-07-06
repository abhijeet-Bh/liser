import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/core/widgets/main_shell.dart';
import 'package:liser/features/home/presentation/pages/home_page.dart';
import 'package:liser/features/library/presentation/pages/library_page.dart';
import 'package:liser/features/library/presentation/pages/all_tracks_page.dart';
import 'package:liser/features/library/presentation/pages/playlists_page.dart';
import 'package:liser/features/library/presentation/pages/playlist_details_page.dart';
import 'package:liser/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:liser/features/settings/presentation/pages/settings_page.dart';
import 'package:liser/features/splash/presentation/pages/splash_page.dart';
import 'package:liser/features/profile/presentation/pages/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'all',
                    builder: (context, state) => const AllTracksPage(),
                  ),
                  GoRoute(
                    path: 'playlists',
                    builder: (context, state) => const PlaylistsPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaylistDetailsPage(playlistId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
