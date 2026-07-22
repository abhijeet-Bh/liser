import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/sharing/data/services/sharing_service.dart';
import 'package:liser/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:liser/features/sharing/presentation/pages/radar_scan_page.dart';
import 'package:liser/features/sharing/presentation/pages/sharing_settings_sheet.dart';

class LiserSharePage extends StatefulWidget {
  const LiserSharePage({super.key});

  @override
  State<LiserSharePage> createState() => _LiserSharePageState();
}

class _LiserSharePageState extends State<LiserSharePage> with SingleTickerProviderStateMixin {
  final SharingService _sharingService = sl<SharingService>();
  late SharingBloc _sharingBloc;
  late AnimationController _pulseController;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _sharingBloc = SharingBloc(sharingService: _sharingService);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sharingBloc.add(ResetSharing());
    _sharingBloc.close();
    super.dispose();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SharingSettingsSheet(
          onSettingsChanged: () {
            setState(() {});
          },
        );
      },
    );
  }

  void _showSongPicker() async {
    final songs = await sl<LibraryRepository>().getSongs();
    
    if (!mounted) return;
    
    if (songs.isEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Empty Library'),
          content: const Text('You do not have any songs in your library to share.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';
        final selectedSongs = <Song>{};
        return StatefulBuilder(
          builder: (stContext, setStateSheet) {
            final filteredSongs = songs.where((s) {
              final text = '${s.title} ${s.artist}'.toLowerCase();
              return text.contains(query.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141417) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Select Tracks to Share',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoSearchTextField(
                          placeholder: 'Search songs...',
                          onChanged: (val) {
                            setStateSheet(() {
                              query = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];
                            final isSelected = selectedSongs.contains(song);
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isSelected ? CupertinoIcons.checkmark_alt : CupertinoIcons.music_note, 
                                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                                onTap: () {
                                  setStateSheet(() {
                                    if (isSelected) {
                                      selectedSongs.remove(song);
                                    } else {
                                      selectedSongs.add(song);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (selectedSongs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RadarScanPage(songs: selectedSongs.toList()),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                selectedSongs.length == 1
                                    ? 'Share Selected Track'
                                    : 'Share Selected (${selectedSongs.length} Tracks)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showReceiveRequestDialog(BuildContext context, PendingTransferRequest request) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    
    bool alwaysTrust = false;
    final totalBytes = request.files.fold<int>(0, (sum, f) => sum + f.fileSize);
    final mbSize = (totalBytes / (1024 * 1024)).toStringAsFixed(1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(CupertinoIcons.square_arrow_down_fill, color: Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  Text(request.files.length == 1 ? 'Incoming Track' : 'Incoming Tracks', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: request.senderName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: request.files.length == 1
                              ? ' wants to share a music track with you:'
                              : ' wants to share ${request.files.length} tracks with you:',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          request.files.length == 1
                              ? CupertinoIcons.music_note_2
                              : CupertinoIcons.music_albums,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.files.length == 1
                                    ? request.files.first.title
                                    : '${request.files.length} Tracks',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                request.files.length == 1
                                    ? '${request.files.first.artist} • $mbSize MB'
                                    : '${request.files.take(2).map((f) => f.title).join(", ")}${request.files.length > 2 ? "..." : ""} • $mbSize MB',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: alwaysTrust,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) {
                          setStateDialog(() {
                            alwaysTrust = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Always trust this device (Pair)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _dialogOpen = false;
                    Navigator.pop(dialogContext);
                    _sharingBloc.add(RespondToRequest(accept: false, alwaysTrust: false));
                  },
                  child: const Text('Decline', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _dialogOpen = false;
                    Navigator.pop(dialogContext);
                    _sharingBloc.add(RespondToRequest(accept: true, alwaysTrust: alwaysTrust));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _sharingBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Liser Share', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.settings),
              onPressed: _showSettingsSheet,
            ),
          ],
        ),
        body: FrostedBackground(
          child: BlocConsumer<SharingBloc, SharingState>(
            listener: (context, state) {
              if (state.status == SharingStatus.connecting && state.pendingRequest != null) {
                _showReceiveRequestDialog(context, state.pendingRequest!);
              }

              if (state.status == SharingStatus.hosting) {
                _pulseController.repeat(reverse: true);
              } else {
                _pulseController.stop();
              }

              if (state.status == SharingStatus.success) {
                context.read<LibraryBloc>().add(LoadLibrary());
              }
            },
            builder: (context, state) {
              final alias = _sharingService.deviceAlias;
              final currentVisibility = _sharingService.visibility;

              if (state.status == SharingStatus.hosting) {
                return _buildHostingView(context, alias, currentVisibility);
              }

              if (state.status == SharingStatus.transferring) {
                return _buildTransferringView(context, state.progress);
              }

              if (state.status == SharingStatus.success) {
                return _buildSuccessView(context, state.successMessage ?? 'Success!');
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      
                      // Central P2P Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildShareButton(
                            title: 'Send',
                            icon: CupertinoIcons.paperplane_fill,
                            color: theme.colorScheme.primary,
                            onTap: () => _showSongPicker(),
                          ),
                          const SizedBox(width: 24),
                          _buildShareButton(
                            title: 'Receive',
                            icon: CupertinoIcons.square_arrow_down_fill,
                            color: const Color(0xFF10B981),
                            onTap: () {
                              _sharingBloc.add(StartReceiveMode());
                            },
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Device Status info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141417).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(CupertinoIcons.device_phone_portrait, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alias,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Visible to: ${currentVisibility.toUpperCase()}',
                                    style: TextStyle(
                                      color: currentVisibility == 'off' ? Colors.redAccent : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.pencil),
                              onPressed: _showSettingsSheet,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141417).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostingView(BuildContext context, String alias, String visibility) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                final opacity = 0.5 - (_pulseController.value * 0.4);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF10B981), blurRadius: 15, spreadRadius: 1)
                        ],
                      ),
                      child: const Icon(CupertinoIcons.wifi, color: Colors.white, size: 40),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Waiting to Receive...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Visible to other Liser players as:\n"$alias"\n(Visibility: ${visibility.toUpperCase()})',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),
            
            // Local IP Info for Hotspot manual connect fallback
            FutureBuilder<String?>(
              future: _sharingService.getLocalIpAddress(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Local IP Address: ${snapshot.data}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {
                _sharingBloc.add(StopReceiveMode());
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferringView(BuildContext context, double progress) {
    final percentage = (progress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    color: const Color(0xFF10B981),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Receiving Track...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Please keep the app open until the transfer completes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.checkmark, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('Done!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                _sharingBloc.add(ResetSharing());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Okay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
