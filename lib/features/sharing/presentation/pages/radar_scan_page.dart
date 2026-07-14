import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/sharing/data/services/sharing_service.dart';
import 'package:liser/features/sharing/presentation/bloc/sharing_bloc.dart';

class RadarScanPage extends StatefulWidget {
  final List<Song> songs;

  const RadarScanPage({super.key, required this.songs});

  @override
  State<RadarScanPage> createState() => _RadarScanPageState();
}

class _RadarScanPageState extends State<RadarScanPage> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  late SharingBloc _sharingBloc;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sharingBloc = SharingBloc(sharingService: sl<SharingService>());
    _sharingBloc.add(StartDiscovery());
  }

  @override
  void dispose() {
    _radarController.dispose();
    _sharingBloc.add(ResetSharing());
    _sharingBloc.close();
    super.dispose();
  }

  void _showManualConnectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C21) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Connect via IP', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the IP Address shown on the receiver\'s screen:',
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.3),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g., 192.168.1.150',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final ip = controller.text.trim();
                if (ip.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  final manualDevice = DiscoveredDevice(
                    ipAddress: ip,
                    port: SharingService.defaultPort,
                    alias: 'Liser Player (IP: $ip)',
                    deviceType: 'unknown',
                    fingerprint: 'manual-$ip',
                    visibility: 'everyone',
                  );
                  _sharingBloc.add(
                    SendSongRequest(
                      target: manualDevice,
                      songs: widget.songs,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Scanning...', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => context.pop(),
          ),
        ),
        body: FrostedBackground(
          child: BlocConsumer<SharingBloc, SharingState>(
            listener: (context, state) {
              if (state.status == SharingStatus.error && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.status == SharingStatus.connecting) {
                return _buildStatusView(
                  icon: CupertinoIcons.link,
                  title: 'Connecting...',
                  subtitle: 'Waiting for ${state.activeDevice?.alias ?? "peer"} to accept transfer request',
                  pulseColor: theme.colorScheme.primary,
                );
              }

              if (state.status == SharingStatus.transferring) {
                return _buildProgressView(
                  title: widget.songs.length == 1 ? 'Sending Track...' : 'Sending Tracks...',
                  subtitle: widget.songs.length == 1
                      ? 'Uploading "${widget.songs.first.title}" to ${state.activeDevice?.alias}'
                      : 'Uploading ${widget.songs.length} tracks to ${state.activeDevice?.alias}',
                  progress: state.progress,
                );
              }

              if (state.status == SharingStatus.success) {
                return _buildSuccessView(
                  title: 'Transfer Completed!',
                  subtitle: state.successMessage ?? 'The track was sent successfully!',
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Device details header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Card(
                        color: isDark ? const Color(0xFF141417).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        borderOnForeground: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  widget.songs.length == 1 
                                      ? CupertinoIcons.music_note_2 
                                      : CupertinoIcons.music_albums, 
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.songs.length == 1 ? 'SELECTED TRACK' : 'SELECTED TRACKS', 
                                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.songs.length == 1 ? widget.songs.first.title : '${widget.songs.length} Tracks', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      widget.songs.length == 1 
                                          ? widget.songs.first.artist 
                                          : widget.songs.map((s) => s.title).join(', '), 
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
                      ),
                    ),
                    const Spacer(),
                    
                    // Radar Animation
                    Center(
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: RadarPainter(_radarController.value, theme.colorScheme.primary),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: const Icon(CupertinoIcons.antenna_radiowaves_left_right, color: Colors.white, size: 36),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Scan subtitle
                    const Text(
                      'Searching for nearby Liser players...',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // Discovered Devices list
                    Expanded(
                      flex: 2,
                      child: state.discoveredDevices.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CupertinoActivityIndicator(),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Make sure both devices are on the same Wi-Fi\nor one is connected to the other\'s hotspot.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              itemCount: state.discoveredDevices.length,
                              itemBuilder: (context, index) {
                                final device = state.discoveredDevices[index];
                                final isAndroid = device.deviceType == 'android';
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF141417).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: CircleAvatar(
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        child: Icon(
                                          isAndroid ? CupertinoIcons.device_phone_portrait : CupertinoIcons.device_phone_portrait,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(device.alias, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        'IP: ${device.ipAddress} • ${device.deviceType.toUpperCase()}',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text('Send', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                      onTap: () {
                                        _sharingBloc.add(
                                          SendSongRequest(
                                            target: device,
                                            songs: widget.songs,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextButton.icon(
                        onPressed: () => _showManualConnectDialog(context),
                        icon: const Icon(CupertinoIcons.link),
                        label: const Text('Connect via IP Manually', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color pulseColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: pulseColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: pulseColor),
            ),
            const SizedBox(height: 32),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView({
    required String title,
    required String subtitle,
    required double progress,
  }) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Circular progress
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
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView({
    required String title,
    required String subtitle,
  }) {
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
            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RadarPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final value = (animationValue + i / 4.0) % 1.0;
      final radius = maxRadius * value;
      final opacity = (1.0 - value) * 0.35;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
