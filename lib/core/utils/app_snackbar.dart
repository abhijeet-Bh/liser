import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum SnackBarType { info, success, error, warning }

class AppSnackBar {
  static void show(
    BuildContext context, 
    String message, {
    SnackBarType type = SnackBarType.info,
  }) {
    Color backgroundColor;
    IconData? icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFF10B981); // Emerald green
        icon = CupertinoIcons.check_mark_circled_solid;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFEF4444); // Red
        icon = CupertinoIcons.exclamationmark_circle_fill;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFF59E0B); // Amber
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = Colors.black.withValues(alpha: 0.85);
        icon = null;
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: icon != null ? TextAlign.left : TextAlign.center,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
