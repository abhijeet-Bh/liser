import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/widgets/frosted_background.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
        toolbarHeight: 80,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 150),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(CupertinoIcons.music_note_list, color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('All Tracks', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                onTap: () {
                  context.push('/library/all');
                },
              ),
              const Divider(height: 1, thickness: 1, indent: 84, endIndent: 24, color: Colors.white10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(CupertinoIcons.music_albums, color: Theme.of(context).colorScheme.secondary),
                ),
                title: const Text('Playlists', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
                onTap: () {
                  context.push('/library/playlists');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
