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

  /// Devuelve el handler si está disponible, o null si AudioService no se inicializó.
  AudioHandler? get _handler =>
      AudioServiceLocator.isReady ? AudioServiceLocator.handler : null;

  /// Engancha listeners al handler. No hace nada si el handler no está disponible.
  void attach() {
    final h = _handler;
    if (h == null) return;
    if (_sub1 != null || _sub2 != null) return; // ya está enganchado

    _sub1 = h.playbackState.listen((_) => notifyListeners());
    _sub2 = h.mediaItem.listen((_) => notifyListeners());
  }

  bool get isPlaying => _handler?.playbackState.value.playing ?? false;

  bool get isBuffering {
    final state = _handler?.playbackState.value;
    if (state == null) return false;
    return state.processingState == AudioProcessingState.buffering ||
        state.processingState == AudioProcessingState.loading;
  }

  bool get isInitialized {
    final item = _handler?.mediaItem.value;
    return item != null && item.id.isNotEmpty;
  }

  String get programTitle => _handler?.mediaItem.value?.title ?? '';
  String? get url => _handler?.mediaItem.value?.id;

  RttAudioHandler? get _rtt => _handler as RttAudioHandler?;

  Future<void> ensureInit(String url, {String title = 'RTT Radio'}) async {
    final rtt = _rtt;
    if (rtt == null) return;
    attach();
    await rtt.ensureInit(url: url, title: title);
    notifyListeners();
  }

  Future<void> setProgramTitle(String title) async {
    final rtt = _rtt;
    if (rtt == null) return;
    attach();
    final currentUrl = url ?? '';
    if (currentUrl.isEmpty) return;
    await rtt.ensureInit(url: currentUrl, title: title);
    notifyListeners();
  }

  Future<void> play() async {
    final h = _handler;
    if (h == null) return;
    attach();
    await h.play();
    notifyListeners();
  }

  Future<void> pause() async {
    final h = _handler;
    if (h == null) return;
    attach();
    await h.pause();
    notifyListeners();
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
