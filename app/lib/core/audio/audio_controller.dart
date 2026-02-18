import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends ChangeNotifier {
  AudioController._() {
    // 🔥 Esto hace que el UI se actualice cuando cambie playing/buffering/completed
    _playerStateSub = _player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  static final AudioController instance = AudioController._();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _initialized = false;
  String? _url;

  /// Para mostrar en el mini-player
  String programTitle = '';

  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  bool get isInitialized => _initialized;
  String? get url => _url;

  Future<void> ensureInit(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return;

    if (_initialized && _url == clean) return;

    _url = clean;
    await _player.setUrl(clean);
    _initialized = true;
    notifyListeners();
  }

  void setProgramTitle(String title) {
    final t = title.trim();
    if (t == programTitle) return;
    programTitle = t;
    notifyListeners();
  }

  Future<void> play() async {
    if (!_initialized) return;
    await _player.play();
    // notifyListeners lo dispara también el stream, pero lo dejamos por seguridad
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

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
