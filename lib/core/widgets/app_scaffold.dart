import 'package:flutter/material.dart';

import 'package:liser/features/player/presentation/widgets/mini_player.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Column(children: [Expanded(child: body), const MiniPlayer()]),
    );
  }
}
