import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'app.dart';
import 'core/audio/audio_controller.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/audio_service_locator.dart';
import 'core/consent/consent_service.dart';
import 'core/favorites/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar estado persistido desde SharedPreferences lo antes posible.
  await FavoritesService.instance.ensureLoaded();
  await ConsentService.instance.ensureLoaded();

  try {
    final handler = await AudioService.init(
      builder: () => RttAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.rtt.app.channel.audio',
        androidNotificationChannelName: 'RTT Audio',
        androidStopForegroundOnPause: false,
      ),
    );
    AudioServiceLocator.setHandler(handler);
    AudioController.instance.attach();
  } catch (e) {
    debugPrint('AudioService init failed: $e');
    // La app sigue funcionando sin audio service en background.
    // Esto puede pasar en emuladores o dispositivos sin soporte completo.
  }

  runApp(RttApp());
}
