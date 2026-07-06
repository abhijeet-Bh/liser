import 'dart:ui';
import 'package:flutter/material.dart';
class FrostedBackground extends StatelessWidget {
  final Widget child;

  const FrostedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Stack(
      children: [
        // Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: isLight ? 0.4 : 0.2),
                Theme.of(context).colorScheme.secondary.withValues(alpha: isLight ? 0.25 : 0.1),
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
