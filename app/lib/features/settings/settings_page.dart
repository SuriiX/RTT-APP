import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/rtt_scaffold.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _kNotifsKey = 'rtt_notifications_enabled';

  bool loading = true;
  bool enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      enabled = sp.getBool(_kNotifsKey) ?? true;
      loading = false;
    });
  }

  Future<void> _setEnabled(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kNotifsKey, v);
    setState(() => enabled = v);

    // OJO: esto no “apaga” la media notification mientras suena;
    // controla si mostramos/pedimos permisos para notificaciones generales.
    // La media notification se gestiona por AudioService al reproducir.
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Ajustes',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: () {},
        ),
      ],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 8),
                _row(
                  icon: Icons.notifications_none,
                  title: 'Notificaciones',
                  trailing: Switch(
                    value: enabled,
                    onChanged: _setEnabled,
                  ),
                  onTap: () => _setEnabled(!enabled),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.lock_outline,
                  title: 'Política de privacidad',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                const Divider(height: 1),
              ],
            ),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Icon(icon, color: const Color(0xFFE53935), size: 26),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
