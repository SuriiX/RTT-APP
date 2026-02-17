import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends ChangeNotifier {
  AudioController._();
  static final AudioController instance = AudioController._();

  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  String? _url;

  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;
  bool get isInitialized => _initialized;
  String? get url => _url;

  /// Llama esto una vez (cuando tengas la URL).
  Future<void> ensureInit(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return;

    if (_initialized && _url == clean) return;

    _url = clean;
    await _player.setUrl(clean);
    _initialized = true;
    notifyListeners();
  }

  Future<void> play() async {
    if (!_initialized) return;
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    if (!_initialized) return;
    await _player.pause();
    notifyListeners();
  }

  Future<void> toggle() async {
    if (!_initialized) return;
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }
}
