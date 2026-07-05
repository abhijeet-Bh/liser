import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:liser/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(repository: sl<OnboardingRepository>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.folderSelected) {
          context.go('/library');
        }

        if (state.status == OnboardingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Something went wrong')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_music_rounded, size: 90),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to Liser',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your music folder to start building your library.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    builder: (context, state) {
                      return FilledButton(
                        onPressed:
                            state.status == OnboardingStatus.loading
                                ? null
                                : () {
                                  context.read<OnboardingBloc>().add(
                                    PickMusicFolderPressed(),
                                  );
                                },
                        child:
                            state.status == OnboardingStatus.loading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Choose Music Folder'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
