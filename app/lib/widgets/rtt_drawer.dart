import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class RttDrawer extends StatelessWidget {
  final String entradasUrl;

  const RttDrawer({
    super.key,
    required this.entradasUrl,
  });

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header (rojo) con logo + texto (simple por ahora)
            Container(
              height: 64,
              color: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text('RTT', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  const Text('RadioTeleTaxi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(context, icon: Icons.home_outlined, label: 'Inicio', route: '/'),
                  _item(context, icon: Icons.article_outlined, label: 'Actualidad', route: '/actualidad'),
                  _item(context, icon: Icons.event_outlined, label: 'Eventos', route: '/eventos'),
                  _item(context, icon: Icons.schedule_outlined, label: 'Programación', route: '/programacion'),
                  _item(context, icon: Icons.confirmation_num_outlined, label: 'Entradas', route: '/entradas'),
                  _item(context, icon: Icons.radio_outlined, label: 'Frecuencias', route: '/frecuencias'),
                  _item(context, icon: Icons.settings_outlined, label: 'Ajustes', route: '/ajustes'),
                ],
              ),
            ),

            // Footer redes (gris oscuro)
            Container(
              height: 64,
              color: const Color(0xFF3E3E3E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialBtn(Icons.facebook, () => _open('https://www.facebook.com/')),
                  _socialBtn(Icons.close, () => _open('https://twitter.com/')), // placeholder icon
                  _socialBtn(Icons.camera_alt_outlined, () => _open('https://www.instagram.com/')),
                  _socialBtn(Icons.chat, () => _open('https://wa.me/34646212121')),
                  _socialBtn(Icons.play_circle_outline, () => _open('https://www.youtube.com/')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, {required IconData icon, required String label, required String route}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE53935)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  Widget _itemExternal(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE53935)),
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _socialBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
    );
  }
}
