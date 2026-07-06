import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8).copyWith(bottom: 150),
            children: [
              _buildSectionHeader(context, 'Library Management'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(CupertinoIcons.folder_badge_plus, color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Import Music', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text('Add songs from your device folders', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                onTap: () {
                  context.read<LibraryBloc>().add(AddSongs());
                },
              ),
              if (!Platform.isIOS) ...[
                const Divider(height: 1, thickness: 1, indent: 84, endIndent: 24, color: Colors.white10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.arrow_2_circlepath, color: Color(0xFF10B981)),
                  ),
                  title: Row(
                    children: [
                      const Text('Sync Folder ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BETA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Automatically sync songs from a selected folder', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                  onTap: () {
                    context.read<LibraryBloc>().add(SyncLibraryFolder());
                  },
                ),
              ],
              const Divider(height: 1, thickness: 1, indent: 84, endIndent: 24, color: Colors.white10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                ),
                title: const Text('Clear Library', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text('Remove all songs and playlists', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                onTap: () {
                  _showClearLibraryDialog(context);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Display'),
              BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  final themeMode = state.settings?.themeMode ?? 0;
                  
                  String themeLabel = 'System';
                  if (themeMode == 1) themeLabel = 'Light';
                  if (themeMode == 2) themeLabel = 'Dark';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.moon_stars, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: const Text('App Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    subtitle: Text(themeLabel, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Select Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<int>(
                                  title: const Text('System', style: TextStyle(fontWeight: FontWeight.w500)),
                                  value: 0,
                                  groupValue: themeMode,
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<AppBloc>().add(UpdateThemeMode(value));
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                ),
                                RadioListTile<int>(
                                  title: const Text('Light', style: TextStyle(fontWeight: FontWeight.w500)),
                                  value: 1,
                                  groupValue: themeMode,
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<AppBloc>().add(UpdateThemeMode(value));
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                ),
                                RadioListTile<int>(
                                  title: const Text('Dark', style: TextStyle(fontWeight: FontWeight.w500)),
                                  value: 2,
                                  groupValue: themeMode,
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<AppBloc>().add(UpdateThemeMode(value));
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showClearLibraryDialog(BuildContext context) {
    final state = context.read<LibraryBloc>().state;
    final songCount = state.songs.length;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 56, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 24),
                  const Text('Clear Library?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'These $songCount songs will be completely deleted from your Liser library. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LibraryBloc>().add(ClearLibrary());
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Delete All', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }
}
