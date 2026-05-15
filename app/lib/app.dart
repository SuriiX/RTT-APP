import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/consent/consent_service.dart';
import 'core/theme/rtt_theme.dart';
import 'features/actualidad/actualidad_detalle_page.dart';
import 'features/actualidad/actualidad_page.dart';
import 'features/alacarta/alacarta_page.dart';
import 'features/alacarta/show_detail_page.dart';
import 'features/entradas/entradas_page.dart';
import 'features/eventos/evento_detalle_page.dart';
import 'features/favorites/favorites_page.dart';
import 'features/frecuencias/frecuencias_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/player/player_page.dart';
import 'features/profile/profile_page.dart';
import 'features/programacion/programacion_page.dart';
import 'features/settings/privacy_policy_page.dart';
import 'features/settings/terms_page.dart';
import 'widgets/app_shell.dart';

class RttApp extends StatelessWidget {
  RttApp({super.key});

  static Page<void> _fadePage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  static final _rootNavKey = GlobalKey<NavigatorState>();
  static final _homeNavKey = GlobalKey<NavigatorState>();
  static final _alacartaNavKey = GlobalKey<NavigatorState>();
  static final _entradasNavKey = GlobalKey<NavigatorState>();
  static final _profileNavKey = GlobalKey<NavigatorState>();

  late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/',
    redirect: (context, state) {
      final consented = ConsentService.instance.hasConsented;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!consented && !goingToOnboarding) return '/onboarding';
      if (consented && goingToOnboarding) return '/';
      return null;
    },
    routes: [
      // Pantallas fuera del shell (sin bottom nav).
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, _) => _fadePage(const OnboardingPage()),
      ),
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavKey,
        pageBuilder: (context, _) => _fadePage(const PlayerPage()),
      ),

      // Shell con bottom navigation + mini-player.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 1: EN DIRECTO (home + sub-rutas)
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, _) => _fadePage(const HomePage()),
                routes: [
                  GoRoute(
                    path: 'actualidad',
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
                    path: 'eventos/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _fadePage(EventoDetallePage(eventId: id));
                    },
                  ),
                  GoRoute(
                    path: 'programacion',
                    pageBuilder: (context, _) => _fadePage(const ProgramacionPage()),
                  ),
                  GoRoute(
                    path: 'frecuencias',
                    pageBuilder: (context, _) => _fadePage(const FrecuenciasPage()),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: A LA CARTA
          StatefulShellBranch(
            navigatorKey: _alacartaNavKey,
            routes: [
              GoRoute(
                path: '/alacarta',
                pageBuilder: (context, _) => _fadePage(const AlaCartaPage()),
                routes: [
                  GoRoute(
                    path: 'show/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _fadePage(ShowDetailPage(showId: id));
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: ENTRADAS
          StatefulShellBranch(
            navigatorKey: _entradasNavKey,
            routes: [
              GoRoute(
                path: '/entradas',
                pageBuilder: (context, _) => _fadePage(const EntradasPage()),
                routes: [
                  GoRoute(
                    path: 'evento/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _fadePage(EventoDetallePage(eventId: id));
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: MI PERFIL
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/perfil',
                pageBuilder: (context, _) => _fadePage(const ProfilePage()),
                routes: [
                  GoRoute(
                    path: 'favoritos',
                    pageBuilder: (context, _) => _fadePage(const FavoritesPage()),
                  ),
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
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RadioTeleTaxi',
      theme: rttTheme(),
      routerConfig: _router,
    );
  }
}
