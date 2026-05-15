import 'package:flutter/material.dart';

import '../core/theme/rtt_theme.dart';

/// AppBar corporativa con el logo circular "RTT" + texto "RadioTeleTaxi".
///
/// El [title] sigue presente pero por defecto solo se muestra el logo: la
/// app principal usa el mismo header en todas las pestañas según los mocks.
class RttAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RttAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBack = false,
    this.showLogoTitle = true,
  });

  final String title;
  final List<Widget> actions;
  final bool showBack;
  final bool showLogoTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final leading = (showBack || canPop)
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : null;

    return AppBar(
      backgroundColor: RttColors.red,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: leading,
      centerTitle: true,
      titleSpacing: 0,
      title: showLogoTitle ? _LogoTitle(title: title) : Text(title),
      actions: actions,
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo_rtt.png',
      height: 36,
      fit: BoxFit.contain,
      semanticLabel: 'RadioTeleTaxi',
    );
  }
}
