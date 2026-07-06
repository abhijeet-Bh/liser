import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import 'package:liser/app/bloc/app_bloc.dart';
import 'package:liser/app/widgets/frosted_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppBloc>().state;
    _nameController.text = state.settings?.userName ?? '';
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
      if (!mounted) return;
      context.read<AppBloc>().add(
        UpdateProfile(userPhotoPath: result.files.single.path!),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
      ),
      body: FrostedBackground(
        child: SafeArea(
          child: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final settings = state.settings;
              final photoPath = settings?.userPhotoPath;
              final themeColorId = settings?.themeColorId ?? 0;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              image: photoPath != null
                                  ? DecorationImage(
                                      image: FileImage(File(photoPath)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoPath == null
                                ? Icon(
                                    CupertinoIcons.person_fill,
                                    size: 60,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NAME',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditingName ? CupertinoIcons.checkmark_alt : CupertinoIcons.pencil, size: 20),
                        onPressed: () {
                          if (_isEditingName) {
                            _saveName(_nameController.text);
                          }
                          setState(() {
                            _isEditingName = !_isEditingName;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isEditingName)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _nameController,
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
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        _nameController.text.isEmpty ? 'Not set' : _nameController.text,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Text(
                    'THEME COLOR',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeCircle(context, 0, themeColorId, 'Liser Purple', const Color(0xFF7C3AED), const Color(0xFF9D4EDD)),
                      _buildThemeCircle(context, 1, themeColorId, 'Midnight Blue', const Color(0xFF2563EB), const Color(0xFF3B82F6)),
                      _buildThemeCircle(context, 2, themeColorId, 'Emerald Green', const Color(0xFF059669), const Color(0xFF10B981)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCircle(BuildContext context, int id, int selectedId, String name, Color c1, Color c2) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: () => _updateThemeColor(id),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
