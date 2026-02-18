import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class RttDrawer extends StatelessWidget {
  const RttDrawer({super.key});

  static const Color rttRed = Color(0xFFE53935);

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: rttRed),
      title: Text(text, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Header rojo como la app antigua
            Container(
              color: rttRed,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
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
                        color: rttRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'RadioTeleTaxi',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, // luego: favoritos
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {}, // luego: compartir
                    icon: const Icon(Icons.ios_share, color: Colors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(context: context, icon: Icons.home_outlined, text: 'Inicio', route: '/'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.newspaper_outlined, text: 'Actualidad', route: '/actualidad'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.calendar_month_outlined, text: 'Eventos', route: '/eventos'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.schedule, text: 'Programación', route: '/programacion'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.confirmation_num_outlined, text: 'Entradas', route: '/entradas'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.wifi_tethering, text: 'Frecuencias', route: '/frecuencias'),
                  const Divider(height: 1),
                  _item(context: context, icon: Icons.settings_outlined, text: 'Ajustes', route: '/ajustes'),
                ],
              ),
            ),

            // Footer social
            Container(
              color: const Color(0xFF4A4A4A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _openUrl('https://www.facebook.com/'),
                    icon: const Icon(Icons.facebook, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _openUrl('https://twitter.com/'),
                    icon: const Icon(Icons.public, color: Colors.white), // placeholder twitter
                  ),
                  IconButton(
                    onPressed: () => _openUrl('https://www.instagram.com/'),
                    icon: const Icon(Icons.camera_alt, color: Colors.white), // placeholder IG
                  ),
                  IconButton(
                    onPressed: () => _openUrl('https://wa.me/34646212121'),
                    icon: const Icon(Icons.chat, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _openUrl('https://www.youtube.com/'),
                    icon: const Icon(Icons.play_circle, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
