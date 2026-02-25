import 'package:flutter/material.dart';

import '../core/theme/rtt_theme.dart';

class RttAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RttAppBar({
    super.key,
    required this.title,
    this.showHamburger = true,
    this.showClose = false,
    this.onClose,
    this.actions = const [],
  });

  final String title;
  final bool showHamburger;
  final bool showClose;
  final VoidCallback? onClose;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RttColors.red,
      elevation: 0,
      leading: showClose
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose ?? () => Navigator.of(context).maybePop(),
            )
          : (showHamburger
              ? Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              : null),
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 6),
          // Logo simple (puedes reemplazar por Image.asset cuando lo tengas)
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.center,
            child: const Text(
              'RTT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: RttColors.red,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
