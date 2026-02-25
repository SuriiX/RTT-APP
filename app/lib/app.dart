import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/consent/consent_service.dart';
import 'core/theme/rtt_theme.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/player/player_page.dart';
import 'features/programacion/programacion_page.dart';
import 'features/frecuencias/frecuencias_page.dart';
import 'features/entradas/entradas_page.dart';
import 'features/actualidad/actualidad_page.dart';
import 'features/actualidad/actualidad_detalle_page.dart';
import 'features/eventos/eventos_page.dart';
import 'features/eventos/evento_detalle_page.dart';
import 'features/favorites/favorites_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/privacy_policy_page.dart';
import 'features/settings/terms_page.dart';

class RttApp extends StatelessWidget {
  RttApp({super.key});

  static Page<void> _fadePage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  final _router = GoRouter(
    redirect: (context, state) {
      final consented = ConsentService.instance.hasConsented;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!consented && !goingToOnboarding) return '/onboarding';
      if (consented && goingToOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, _) => _fadePage(const OnboardingPage()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, _) => _fadePage(const HomePage()),
      ),

      GoRoute(
        path: '/actualidad',
        pageBuilder: (context, _) => _fadePage(const ActualidadPage()),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _fadePage(ActualidadDetallePage(postId: id));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/eventos',
        pageBuilder: (context, _) => _fadePage(const EventosPage()),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _fadePage(EventoDetallePage(eventId: id));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/programacion',
        pageBuilder: (context, _) => _fadePage(const ProgramacionPage()),
      ),
      GoRoute(
        path: '/entradas',
        pageBuilder: (context, _) => _fadePage(const EntradasPage()),
      ),

      GoRoute(
        path: '/frecuencias',
        pageBuilder: (context, _) => _fadePage(const FrecuenciasPage()),
      ),

      GoRoute(
        path: '/favoritos',
        pageBuilder: (context, _) => _fadePage(const FavoritesPage()),
      ),

      // ✅ Settings real
      GoRoute(
        path: '/ajustes',
        pageBuilder: (context, _) => _fadePage(const SettingsPage()),
        routes: [
          GoRoute(
            path: 'privacidad',
            pageBuilder: (context, _) => _fadePage(const PrivacyPolicyPage()),
          ),
          GoRoute(
            path: 'terminos',
            pageBuilder: (context, _) => _fadePage(const TermsPage()),
          ),
        ],
      ),

      GoRoute(
        path: '/player',
        pageBuilder: (context, _) => _fadePage(const PlayerPage()),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RTT APP',
      theme: rttTheme(),
      routerConfig: _router,
    );
  }
}
