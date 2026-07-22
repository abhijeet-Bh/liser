import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/sharing/data/services/sharing_service.dart';

class SharingSettingsSheet extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const SharingSettingsSheet({super.key, required this.onSettingsChanged});

  @override
  State<SharingSettingsSheet> createState() => _SharingSettingsSheetState();
}

class _SharingSettingsSheetState extends State<SharingSettingsSheet> {
  final SharingService _sharingService = sl<SharingService>();
  late TextEditingController _nameController;
  late String _currentVisibility;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _sharingService.deviceAlias);
    _currentVisibility = _sharingService.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      _sharingService.deviceAlias = newName;
      widget.onSettingsChanged();
    }
  }

  void _changeVisibility(String visibility) {
    setState(() {
      _currentVisibility = visibility;
      _sharingService.visibility = visibility;
    });
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final paired = _sharingService.pairedDevices;

    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141417) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Liser Share Settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // Device Name Textfield
                const Text(
                  'DEVICE NAME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => _saveName(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.device_phone_portrait),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    hintText: 'Enter device name',
                  ),
                ),
                const SizedBox(height: 28),

                // Visibility Section
                const Text(
                  'VISIBILITY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C21) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildVisibilityTile(
                        title: 'Everyone',
                        subtitle: 'Visible to all Liser devices nearby',
                        value: 'everyone',
                        icon: CupertinoIcons.globe,
                        color: const Color(0xFF10B981),
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16, color: Colors.white10),
                      _buildVisibilityTile(
                        title: 'Known People Only',
                        subtitle: 'Only visible to paired/trusted devices',
                        value: 'known',
                        icon: CupertinoIcons.person_2_fill,
                        color: Colors.orange,
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16, color: Colors.white10),
                      _buildVisibilityTile(
                        title: 'Off',
                        subtitle: 'Invisible to everyone',
                        value: 'off',
                        icon: CupertinoIcons.eye_slash_fill,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Paired Devices Section
                const Text(
                  'TRUSTED / PAIRED DEVICES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                if (paired.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C21) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      children: [
                        Icon(CupertinoIcons.shield, color: Colors.grey, size: 28),
                        SizedBox(height: 8),
                        Text(
                          'No paired devices yet',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C21) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paired.length,
                      separatorBuilder: (context, _) => const Divider(height: 1, indent: 56, color: Colors.white10),
                      itemBuilder: (context, index) {
                        final device = paired[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(CupertinoIcons.device_phone_portrait, color: theme.colorScheme.primary),
                            ),
                            title: Text(device['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Trusted Partner', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(CupertinoIcons.xmark_circle, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _sharingService.unpairDevice(device['fingerprint'] ?? '');
                                });
                                widget.onSettingsChanged();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _currentVisibility == value;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _changeVisibility(value),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark_alt_circle_fill, color: theme.colorScheme.primary, size: 22)
            else
              const Icon(CupertinoIcons.circle, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}
