import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/rtt_theme.dart';
import 'mini_player.dart';

/// Shell raíz de la app: bottom navigation con 4 pestañas + mini-player
/// persistente. Cada tab conserva su estado de navegación gracias a
/// `StatefulShellRoute.indexedStack`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Material(
        elevation: 12,
        color: const Color(0xFF1B1B1B),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RttMiniPlayer(),
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.podcasts_rounded,
                      label: 'En directo',
                      selected: navigationShell.currentIndex == 0,
                      onTap: () => _goTab(0),
                    ),
                    _NavItem(
                      icon: Icons.headphones_rounded,
                      label: 'A la carta',
                      selected: navigationShell.currentIndex == 1,
                      onTap: () => _goTab(1),
                    ),
                    _NavItem(
                      icon: Icons.confirmation_num_outlined,
                      label: 'Entradas',
                      selected: navigationShell.currentIndex == 2,
                      onTap: () => _goTab(2),
                    ),
                    _NavItem(
                      icon: Icons.person_outline,
                      label: 'Mi perfil',
                      selected: navigationShell.currentIndex == 3,
                      onTap: () => _goTab(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTab(int index) {
    navigationShell.goBranch(
      index,
      // Si re-tocas la tab activa vuelve a la raíz de ese branch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? RttColors.red : Colors.white;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
