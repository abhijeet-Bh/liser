import 'package:go_router/go_router.dart';
import 'package:liser/features/library/presentation/pages/library_page.dart';
import 'package:liser/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:liser/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryPage(),
      ),
    ],
  );
}
