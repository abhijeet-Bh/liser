import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/widgets/warning_dialog.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:liser/features/onboarding/presentation/bloc/onboarding_bloc.dart';

import 'package:liser/core/utils/app_toast.dart';

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
          context.read<LibraryBloc>().add(LoadLibrary());
          context.go('/library');
        }

        if (state.status == OnboardingStatus.error) {
          AppToast.show(context, state.error ?? 'Something went wrong');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary.withValues(alpha: Theme.of(context).brightness == Brightness.light ? 0.3 : 0.1),
                Theme.of(context).colorScheme.secondary.withValues(alpha: Theme.of(context).brightness == Brightness.light ? 0.15 : 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        CupertinoIcons.music_albums,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Welcome to Liser',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Platform.isAndroid
                          ? 'Import music files directly or select a folder to sync with your library.'
                          : 'Import music files to start building your beautiful library.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 56),
                    BlocBuilder<OnboardingBloc, OnboardingState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 8,
                                  shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                                onPressed: state.status == OnboardingStatus.loading
                                    ? null
                                    : () {
                                        showWarningDialog(
                                          context: context,
                                          title: 'Import Music',
                                          message: 'The selected songs will be imported into the app.',
                                          icon: CupertinoIcons.folder_badge_plus,
                                          iconColor: Theme.of(context).colorScheme.primary,
                                          confirmText: 'Import',
                                          onConfirm: () {
                                            context.read<OnboardingBloc>().add(
                                              PickMusicFolderPressed(),
                                            );
                                          },
                                        );
                                      },
                                child: state.status == OnboardingStatus.loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Import Music',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            if (Platform.isAndroid) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  onPressed: state.status == OnboardingStatus.loading
                                      ? null
                                      : () {
                                          showWarningDialog(
                                            context: context,
                                            title: 'Sync Folder',
                                            message: 'The app will sync and play songs directly from the selected folder. No files will be copied.',
                                            icon: CupertinoIcons.arrow_2_circlepath,
                                            iconColor: const Color(0xFF10B981),
                                            confirmText: 'Sync',
                                            onConfirm: () {
                                              context.read<OnboardingBloc>().add(
                                                SyncFolderPressed(),
                                              );
                                            },
                                          );
                                        },
                                  child: const Text(
                                    'Sync Folder',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: state.status == OnboardingStatus.loading
                                  ? null
                                  : () {
                                      context.read<OnboardingBloc>().add(SkipOnboarding());
                                    },
                              child: const Text(
                                "I'll do it later",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
