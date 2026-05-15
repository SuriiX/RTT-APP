import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/audio_controller.dart';
import '../core/theme/rtt_theme.dart';

/// Mini-player rojo persistente que aparece sobre la bottom navigation.
///
/// Diseño según mock: barra roja con botón play/pause grande a la izquierda,
/// dos líneas de texto centradas ("EMISIÓN EN DIRECTO" + nombre del programa)
/// y un indicador visual de "waveform" (decorativo) a la derecha.
class RttMiniPlayer extends StatelessWidget {
  const RttMiniPlayer({super.key});

  static const double height = 68;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AudioController.instance,
      builder: (context, _) {
        final ctrl = AudioController.instance;
        if (!ctrl.isInitialized) return const SizedBox.shrink();

        final playing = ctrl.isPlaying;
        final buffering = ctrl.isBuffering;
        final title = ctrl.programTitle.isNotEmpty
            ? ctrl.programTitle
            : 'Radio TeleTaxi';

        return Material(
          color: RttColors.red,
          child: InkWell(
            onTap: () => context.push('/player'),
            child: SizedBox(
              height: height,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  _PlayButton(
                    playing: playing,
                    buffering: buffering,
                    onPressed: ctrl.toggle,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMISIÓN EN DIRECTO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _Waveform(),
                  const SizedBox(width: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.buffering,
    required this.onPressed,
  });

  final bool playing;
  final bool buffering;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 1.6)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: buffering ? null : onPressed,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: buffering
                  ? const SizedBox(
                      key: ValueKey('buf'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(playing),
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    // Decorativo, sin animación pesada — un patrón de barras blancas.
    final heights = const [10.0, 18.0, 26.0, 14.0, 22.0, 10.0, 18.0, 26.0, 14.0];
    return SizedBox(
      height: 36,
      width: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final h in heights) ...[
            Container(
              width: 2.6,
              height: h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}
