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
              _buildSectionHeader(context, 'Library'),
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
}
