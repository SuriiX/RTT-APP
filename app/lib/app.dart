import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/player/player_page.dart';
import 'widgets/rtt_scaffold.dart';
import 'features/programacion/programacion_page.dart';
import 'features/frecuencias/frecuencias_page.dart';

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
        builder: (context, _) => const _SimplePage(title: 'Actualidad'),
      ),
      GoRoute(
        path: '/eventos',
        builder: (context, _) => const _SimplePage(title: 'Eventos'),
      ),
      GoRoute(
        path: '/programacion',
        builder: (context, _) => const ProgramacionPage(),
      ),
      GoRoute(
        path: '/entradas',
        builder: (context, _) => const _SimplePage(title: 'Entradas'),
      ),
      GoRoute(
        path: '/frecuencias',
        builder: (context, _) => const FrecuenciasPage(),
      ),
      GoRoute(
        path: '/ajustes',
        builder: (context, _) => const _SimplePage(title: 'Ajustes'),
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

class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: title,
      body: const Center(
        child: Text('Pendiente de construir'),
      ),
    );
  }
}
