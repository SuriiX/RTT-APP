import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'app.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/audio_service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: () => RttAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rtt.app.channel.audio',
      androidNotificationChannelName: 'RTT Audio',
      androidStopForegroundOnPause: false,
      // ✅ QUITADO: androidNotificationOngoing
    ),
  );

  AudioServiceLocator.setHandler(handler);

  runApp(RttApp());
}
