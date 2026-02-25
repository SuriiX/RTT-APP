import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/consent/consent_service.dart';
import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_scaffold.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';

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
  }

  // --------------- DELETE DATA ---------------

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mis datos'),
        content: const Text(
          'Se borraran todos tus datos locales: favoritos, preferencias '
          'y consentimiento legal.\n\nEsta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAllData();
            },
            style: FilledButton.styleFrom(backgroundColor: RttColors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    // 1. Limpiar servicios
    await FavoritesService.instance.clearAll();
    await ConsentService.instance.clearConsent();

    // 2. Limpiar todo SharedPreferences (notifs, etc.)
    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    if (!mounted) return;

    // 3. Feedback + redirigir al onboarding
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos eliminados correctamente')),
    );
    context.go('/onboarding');
  }

  // --------------- BUILD ---------------

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Ajustes',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: () => Share.share(
            'Descarga la app de RadioTeleTaxi: https://radioteletaxi.com',
          ),
        ),
      ],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // ── General ──
                _sectionHeader('General'),
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
                  title: 'Politica de privacidad',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                  ),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.description_outlined,
                  title: 'Terminos de servicio',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsPage()),
                  ),
                ),

                // ── Información ──
                _sectionHeader('Informacion'),
                _row(
                  icon: Icons.info_outline,
                  title: 'Sobre la app',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'RadioTeleTaxi',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '\u00a9 2025 Radio Tele Taxi',
                    applicationIcon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: RttColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'RTT',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.article_outlined,
                  title: 'Licencias de codigo abierto',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'RadioTeleTaxi',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '\u00a9 2025 Radio Tele Taxi',
                  ),
                ),

                // ── Datos ──
                _sectionHeader('Datos'),
                _row(
                  icon: Icons.delete_outline,
                  title: 'Eliminar mis datos',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _confirmDelete,
                  destructive: true,
                ),
              ],
            ),
    );
  }

  // --------------- HELPERS ---------------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: RttColors.textSecondary,
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Icon(
                icon,
                color: destructive ? RttColors.red : RttColors.red,
                size: 26,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: destructive ? RttColors.red : null,
                  fontWeight: destructive ? FontWeight.w600 : null,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
