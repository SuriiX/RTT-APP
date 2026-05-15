import 'package:flutter/material.dart';

import '../core/theme/rtt_theme.dart';
import 'rtt_app_bar.dart';

/// Scaffold base de cada pantalla. La barra de navegación inferior y el
/// mini-player se renderizan en [AppShell] (un nivel por encima), así que
/// aquí solo nos preocupamos de la AppBar y el cuerpo.
class RttScaffold extends StatelessWidget {
  const RttScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.showBackButton = false,

    /// Cuando se invoca desde una pantalla "fuera del shell" (p. ej. PlayerPage),
    /// el [AppShell] no está presente y, por compatibilidad, esta opción permite
    /// añadir padding inferior para no chocar con un mini-player ajeno.
    this.bottomPadding = 0,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool showBackButton;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RttColors.background,
      appBar: RttAppBar(
        title: title,
        actions: actions,
        showBack: showBackButton,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: body,
      ),
    );
  }
}
