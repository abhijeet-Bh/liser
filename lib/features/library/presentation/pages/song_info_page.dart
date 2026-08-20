import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/core/constants/app_constants.dart';
import 'package:liser/core/constants/layout_constants.dart';

class SongInfoPage extends StatelessWidget {
  final Song song;

  const SongInfoPage({super.key, required this.song});

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Song Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: LayoutConstants.pageBottomPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (song.artworkPath != null && File(song.artworkPath!).existsSync())
              Hero(
                tag: 'artwork_${song.id}',
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.circularLg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: DecorationImage(
                      image: FileImage(File(song.artworkPath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Hero(
                tag: 'artwork_${song.id}',
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: AppRadius.circularLg,
                  ),
                  child: Icon(
                    CupertinoIcons.music_note,
                    size: 60,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.play_circle_fill, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${song.playCount} Plays',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.artist,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: AppRadius.circularLg,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildInfoItem(context, 'Title', song.title, icon: CupertinoIcons.music_note_list),
                  _buildInfoItem(context, 'Artist', song.artist, icon: CupertinoIcons.person_alt),
                  _buildInfoItem(context, 'Album', song.album, icon: CupertinoIcons.square_stack_3d_up),
                  if (song.albumArtist.isNotEmpty && song.albumArtist != '<unknown>')
                    _buildInfoItem(context, 'Album Artist', song.albumArtist, icon: CupertinoIcons.person_2_alt),
                  _buildInfoItem(context, 'Genre', song.genre, icon: CupertinoIcons.guitars),
                  _buildInfoItem(context, 'Year', song.year > 0 ? song.year.toString() : 'Unknown', icon: CupertinoIcons.calendar),
                  _buildInfoItem(context, 'Track Number', song.trackNumber > 0 ? song.trackNumber.toString() : 'Unknown', icon: CupertinoIcons.number),
                  if (song.discNumber > 0)
                    _buildInfoItem(context, 'Disc Number', song.discNumber.toString(), icon: CupertinoIcons.circle_grid_hex),
                  const Divider(),
                  _buildInfoItem(context, 'Duration', _formatDuration(song.duration), icon: CupertinoIcons.time),
                  _buildInfoItem(context, 'File Size', _formatFileSize(song.fileSize), icon: CupertinoIcons.doc_text),
                  _buildInfoItem(context, 'Quality', song.isLossless ? 'Lossless' : 'Standard', icon: CupertinoIcons.waveform),
                  _buildInfoItem(context, 'Source', song.sourceMode.toUpperCase(), icon: CupertinoIcons.device_phone_portrait),
                  const Divider(),
                  _buildInfoItem(context, 'File Path', song.path, icon: CupertinoIcons.folder),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
