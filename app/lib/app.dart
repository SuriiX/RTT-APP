import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/player/player_page.dart';
import 'features/programacion/programacion_page.dart';
import 'features/frecuencias/frecuencias_page.dart';
import 'features/entradas/entradas_page.dart';
import 'features/actualidad/actualidad_page.dart';
import 'features/actualidad/actualidad_detalle_page.dart';
import 'features/eventos/eventos_page.dart';
import 'features/eventos/evento_detalle_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/privacy_policy_page.dart';

class RttApp extends StatelessWidget {
  RttApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => const HomePage(),
      ),

      GoRoute(
        path: '/actualidad',
        builder: (context, _) => const ActualidadPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ActualidadDetallePage(postId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/eventos',
        builder: (context, _) => const EventosPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventoDetallePage(eventId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/programacion',
        builder: (context, _) => const ProgramacionPage(),
      ),
      GoRoute(
        path: '/entradas',
        builder: (context, _) => const EntradasPage(),
      ),

      GoRoute(
        path: '/frecuencias',
        builder: (context, _) => const FrecuenciasPage(),
      ),

      // ✅ Settings real
      GoRoute(
        path: '/ajustes',
        builder: (context, _) => const SettingsPage(),
        routes: [
          // ✅ Subruta: Política de privacidad
          GoRoute(
            path: 'privacidad',
            builder: (context, _) => const PrivacyPolicyPage(),
          ),
        ],
      ),

      // ✅ Player real
      GoRoute(
        path: '/player',
        builder: (context, _) => const PlayerPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RTT APP',
      routerConfig: _router,
    );
  }
}

