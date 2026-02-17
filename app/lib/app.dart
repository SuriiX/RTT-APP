import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/player/player_page.dart';
import 'features/actualidad/actualidad_page.dart';
import 'features/eventos/eventos_page.dart';
import 'features/programacion/programacion_page.dart';
import 'features/frecuencias/frecuencias_page.dart';
import 'features/ajustes/ajustes_page.dart';
import 'features/entradas/entradas_page.dart';

class RttApp extends StatelessWidget {
  const RttApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              drawer: const _MainDrawer(),
              body: child,
            );
          },
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomePage()),
            GoRoute(path: '/player', builder: (_, __) => const PlayerPage()),
            GoRoute(path: '/actualidad', builder: (_, __) => const ActualidadPage()),
            GoRoute(path: '/eventos', builder: (_, __) => const EventosPage()),
            GoRoute(path: '/programacion', builder: (_, __) => const ProgramacionPage()),
            GoRoute(path: '/frecuencias', builder: (_, __) => const FrecuenciasPage()),
            GoRoute(path: '/ajustes', builder: (_, __) => const AjustesPage()),
            GoRoute(path: '/entradas', builder: (_, __) => const EntradasPage()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RTT APP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE53935),
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}

class _MainDrawer extends StatelessWidget {
  const _MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              color: const Color(0xFFE53935),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'RadioTeleTaxi',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _item(context, Icons.home_outlined, 'Inicio', '/'),
            _item(context, Icons.article_outlined, 'Actualidad', '/actualidad'),
            _item(context, Icons.event_outlined, 'Eventos', '/eventos'),
            _item(context, Icons.schedule_outlined, 'Programación', '/programacion'),
            _item(context, Icons.confirmation_num_outlined, 'Entradas', '/entradas'),
            _item(context, Icons.radio_outlined, 'Frecuencias', '/frecuencias'),
            _item(context, Icons.settings_outlined, 'Ajustes', '/ajustes'),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE53935)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
