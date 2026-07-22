import 'package:flutter/material.dart';

class AppToast {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 120, left: 48, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
