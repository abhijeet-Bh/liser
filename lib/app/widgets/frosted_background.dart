import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liser/app/theme/app_colors.dart';

class FrostedBackground extends StatelessWidget {
  final Widget child;

  const FrostedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Container(color: Colors.transparent),
        ),

        // Content
        child,
      ],
    );
  }
}
