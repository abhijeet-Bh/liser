import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:liser/features/profile/presentation/widgets/profile_picture_widget.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;
  int _totalSongs = 0;
  int _totalPlaylists = 0;
  int _totalFavorites = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppBloc>().state;
    _nameController.text = state.settings?.userName ?? '';
    _loadStatsAndVersion();
  }

  Future<void> _loadStatsAndVersion() async {
    try {
      final repo = sl<LibraryRepository>();
      final songs = await repo.getSongs();
      final playlists = await repo.getPlaylists();
      final favorites = songs.where((s) => s.favorite).length;

      if (mounted) {
        setState(() {
          _totalSongs = songs.length;
          _totalPlaylists = playlists.length;
          _totalFavorites = favorites;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final originalFile = File(result.files.single.path!);
      final docsDir = await getApplicationDocumentsDirectory();
      final extension = p.extension(originalFile.path);
      final newPath = p.join(docsDir.path, 'profile_picture$extension');

      await originalFile.copy(newPath);

      if (!mounted) return;
      context.read<AppBloc>().add(
        UpdateProfile(userPhotoPath: newPath),
      );
    }
  }

  void _saveName(String name) {
    context.read<AppBloc>().add(
      UpdateProfile(userName: name),
    );
  }

  void _updateThemeColor(int themeColorId) {
    context.read<AppBloc>().add(UpdateThemeColor(themeColorId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final settings = state.settings;
              final photoPath = settings?.userPhotoPath;
              final themeColorId = settings?.themeColorId ?? 0;
              final userName = _nameController.text.trim().isEmpty
                  ? 'Music Lover'
                  : _nameController.text.trim();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SizedBox(height: 12),

                  // Hero Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ProfilePictureWidget(
                                  photoPath: photoPath,
                                  size: 110,
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.camera_fill,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Editable Name Field
                        if (_isEditingName)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _nameController,
                                    autofocus: true,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter your name',
                                    ),
                                    onSubmitted: (name) {
                                      _saveName(name);
                                      setState(() {
                                        _isEditingName = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                icon: const Icon(CupertinoIcons.checkmark, size: 20),
                                onPressed: () {
                                  _saveName(_nameController.text);
                                  setState(() {
                                    _isEditingName = false;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingName = true;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userName,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.pencil_circle_fill,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Library Stats Card
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Tracks',
                          count: '$_totalSongs',
                          icon: CupertinoIcons.music_note_2,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Playlists',
                          count: '$_totalPlaylists',
                          icon: CupertinoIcons.music_albums,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Favorites',
                          count: '$_totalFavorites',
                          icon: CupertinoIcons.heart_fill,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Theme Customization Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APPEARANCE & THEME',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildThemeCircle(
                              context,
                              id: 0,
                              selectedId: themeColorId,
                              name: 'Liser Purple',
                              c1: const Color(0xFF7C3AED),
                              c2: const Color(0xFF9D4EDD),
                            ),
                            _buildThemeCircle(
                              context,
                              id: 1,
                              selectedId: themeColorId,
                              name: 'Midnight Blue',
                              c1: const Color(0xFF2563EB),
                              c2: const Color(0xFF3B82F6),
                            ),
                            _buildThemeCircle(
                              context,
                              id: 2,
                              selectedId: themeColorId,
                              name: 'Emerald Green',
                              c1: const Color(0xFF059669),
                              c2: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCircle(
    BuildContext context, {
    required int id,
    required int selectedId,
    required String name,
    required Color c1,
    required Color c2,
  }) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: () => _updateThemeColor(id),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [c1, c2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c1.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
                ),
              ),
              if (isSelected)
                const Icon(
                  CupertinoIcons.checkmark_alt,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

