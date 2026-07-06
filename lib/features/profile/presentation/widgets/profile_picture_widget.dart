import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ProfilePictureWidget extends StatefulWidget {
  final String? photoPath;
  final double size;

  const ProfilePictureWidget({super.key, this.photoPath, this.size = 40});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  late Future<File?> _futureFile;

  @override
  void initState() {
    super.initState();
    _futureFile = _getResolvedFile(widget.photoPath);
  }

  @override
  void didUpdateWidget(covariant ProfilePictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPath != widget.photoPath) {
      setState(() {
        _futureFile = _getResolvedFile(widget.photoPath);
      });
    }
  }

  Future<File?> _getResolvedFile(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;
    
    // Always use the basename so it works across app updates/reinstalls 
    // where the App's Sandbox UUID changes.
    final fileName = p.basename(photoPath);
    final docsDir = await getApplicationDocumentsDirectory();
    final resolvedPath = p.join(docsDir.path, fileName);
    
    final file = File(resolvedPath);
    if (await file.exists()) {
      return file;
    }
    
    // Fallback: Check if the original absolute path still somehow exists
    final originalFile = File(photoPath);
    if (await originalFile.exists()) {
      return originalFile;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: FutureBuilder<File?>(
        future: _futureFile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return ClipOval(
              child: Image.file(
                snapshot.data!,
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
              ),
            );
          }
          
          return Icon(
            CupertinoIcons.person_fill,
            color: Theme.of(context).colorScheme.primary,
            size: widget.size * 0.5,
          );
        },
      ),
    );
  }
}
