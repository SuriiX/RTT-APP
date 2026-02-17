import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RttDrawer extends StatelessWidget {
  const RttDrawer({super.key});

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
