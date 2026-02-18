import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class RttAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  String? _url;
  String _title = 'RTT Radio';
  bool _initialized = false;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;

  RttAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Audio focus (importante en Android/iOS)
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Propagar estado del player -> playbackState (para notificación)
    _playerStateSub = _player.playerStateStream.listen((state) {
      final playing = _player.playing;

      final processingState = switch (state.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      };

      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            // MediaControl.rewind, // quítalo si no lo usas
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1],
          processingState: processingState,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
        ),
      );
    });

    // En caso de error de reproducción
    _playbackEventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            playing: false,
          ),
        );
      },
    );
  }

  // ---------- API pública para tu app ----------
  bool get isInitialized => _initialized;
  bool get isPlaying => _player.playing;
  String? get url => _url;
  String get title => _title;

  Future<void> ensureInit({
    required String url,
    required String title,
  }) async {
    final clean = url.trim();
    if (clean.isEmpty) return;

    final t = title.trim().isEmpty ? 'RTT Radio' : title.trim();

    // Si ya está inicializado con la misma URL, solo actualiza metadata
    if (_initialized && _url == clean) {
      if (_title != t) {
        _title = t;
        _updateMediaItem();
      }
      return;
    }

    _url = clean;
    _title = t;

    _updateMediaItem();

    // Para streaming: AudioSource.uri
    await _player.setAudioSource(AudioSource.uri(Uri.parse(clean)));

    _initialized = true;
  }

  void _updateMediaItem() {
    mediaItem.add(
      MediaItem(
        id: _url ?? 'rtt_stream',
        title: _title,
        artist: 'Radio TeleTaxi',
        album: 'Directo',
        // artUri: Uri.parse('https://.../cover.png'),
      ),
    );
  }

  // ---------- Controles desde notificación ----------
  @override
  Future<void> play() async {
    if (!_initialized) return;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    if (!_initialized) return;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    // Detener audio
    await _player.stop();

    // Publicar estado "stopped" para que la notificación se actualice bien
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );

    await super.stop();

    // Si quieres que "Stop" cierre TODO (para liberar recursos):
    await _player.dispose();
    await _playerStateSub?.cancel();
    await _playbackEventSub?.cancel();
  }

  /// Opcional: si quieres cerrar manualmente desde tu app
  Future<void> close() async {
    await stop();
  }
}
