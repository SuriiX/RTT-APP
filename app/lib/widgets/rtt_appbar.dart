import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class RttAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showPlayButton;
  final String phoneNumber; // e.g. "+3493...." or "tel:..."

  const RttAppBar({
    super.key,
    this.showPlayButton = true,
    required this.phoneNumber,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _call() async {
    final uri = Uri.parse('tel:$phoneNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          // “Logo” placeholder (luego lo cambiamos por imagen si quieres)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('RTT', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          const Text('RadioTeleTaxi', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Llamar',
          onPressed: _call,
          icon: const Icon(Icons.phone),
        ),
        if (showPlayButton)
          IconButton(
            tooltip: 'Directo',
            onPressed: () => context.go('/player'),
            icon: const Icon(Icons.play_circle_fill),
          ),
        const SizedBox(width: 6),
      ],
    );
  }
}
