import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/audio_controller.dart';
import 'rtt_app_bar.dart';
import 'rtt_drawer.dart';

class RttScaffold extends StatelessWidget {
  const RttScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.showPlayerBar = true,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool showPlayerBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const RttDrawer(),
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: RttAppBar(
        title: title,
        actions: actions,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: showPlayerBar ? 64 : 0),
            child: body,
          ),
          if (showPlayerBar)
            Positioned(left: 0, right: 0, bottom: 0, child: _MiniPlayerBar()),
        ],
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  static const Color rttRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AudioController.instance,
      builder: (context, _) {
        final ctrl = AudioController.instance;
        final playing = ctrl.isPlaying;

        // Si aún no está init, igual mostramos barra (como app antigua)
        final subtitle = ctrl.programTitle.isNotEmpty ? ctrl.programTitle : 'En directo';

        return Material(
          elevation: 10,
          child: Container(
            height: 64,
            color: rttRed,
            child: Row(
              children: [
                InkWell(
                  onTap: () => ctrl.toggle(),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFFB71C1C),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => context.go('/player'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESCÚCHANOS EN DIRECTO',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(subtitle, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
