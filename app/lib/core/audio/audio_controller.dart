import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';

import 'audio_service_locator.dart';
import 'audio_handler.dart';

class AudioController extends ChangeNotifier {
  AudioController._();

  static final AudioController instance = AudioController._();

  StreamSubscription<PlaybackState>? _sub1;
  StreamSubscription<MediaItem?>? _sub2;

  AudioHandler get _handler => AudioServiceLocator.handler;

  /// Importante: llama esto una vez (ej: en el primer build del Home o Player)
  /// para enganchar listeners cuando el handler ya existe.
  void attach() {
    if (_sub1 != null || _sub2 != null) return; // ya está enganchado

    _sub1 = _handler.playbackState.listen((_) => notifyListeners());
    _sub2 = _handler.mediaItem.listen((_) => notifyListeners());
  }

  bool get isPlaying => _handler.playbackState.value.playing;

  bool get isInitialized {
    final item = _handler.mediaItem.value;
    return item != null && item.id.isNotEmpty;
  }

  String get programTitle => _handler.mediaItem.value?.title ?? '';
  String? get url => _handler.mediaItem.value?.id;

  RttAudioHandler get _rtt => _handler as RttAudioHandler;

  Future<void> ensureInit(String url, {String title = 'RTT Radio'}) async {
    attach();
    await _rtt.ensureInit(url: url, title: title);
    notifyListeners();
  }

  Future<void> setProgramTitle(String title) async {
    attach();
    final currentUrl = url ?? '';
    if (currentUrl.isEmpty) return;
    await _rtt.ensureInit(url: currentUrl, title: title);
    notifyListeners();
  }

  Future<void> play() async {
    attach();
    await _handler.play();
  }

  Future<void> pause() async {
    attach();
    await _handler.pause();
  }

  Future<void> toggle() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  void dispose() {
    _sub1?.cancel();
    _sub2?.cancel();
    super.dispose();
  }
}
