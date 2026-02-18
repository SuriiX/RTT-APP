import 'package:audio_service/audio_service.dart';

class AudioServiceLocator {
  AudioServiceLocator._();

  static AudioHandler? _handler;

  static void setHandler(AudioHandler handler) {
    _handler = handler;
  }

  static AudioHandler get handler {
    final h = _handler;
    if (h == null) {
      throw StateError(
        'AudioHandler no inicializado. Llama AudioServiceLocator.setHandler(...) en main() antes de usar AudioController.',
      );
    }
    return h;
  }

  static bool get isReady => _handler != null;
}
