import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/consent/consent_service.dart';
import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_scaffold.dart';

/// Pantalla "Mi Perfil": acceso a favoritos, programación, frecuencias,
/// preferencias de notificaciones, legales y eliminación de datos (GDPR).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _kNotifsKey = 'rtt_notifications_enabled';

  bool _loading = true;
  bool _notifsEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifsEnabled = sp.getBool(_kNotifsKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _setNotifs(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kNotifsKey, v);
    setState(() => _notifsEnabled = v);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mis datos'),
        content: const Text(
          'Se borrarán todos tus datos locales: favoritos, preferencias y '
          'consentimiento legal.\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAll();
            },
            style: FilledButton.styleFrom(backgroundColor: RttColors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAll() async {
    await FavoritesService.instance.clearAll();
    await ConsentService.instance.clearConsent();
    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos eliminados correctamente')),
    );
    context.go('/onboarding');
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Mi Perfil',
      actions: [
        IconButton(
          tooltip: 'Compartir la app',
          icon: const Icon(Icons.ios_share),
          onPressed: () => Share.share(
            'Descarga la app de RadioTeleTaxi: https://radioteletaxi.com',
          ),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _section('Contenidos'),
                _row(
                  icon: Icons.favorite_outline,
                  title: 'Favoritos',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/perfil/favoritos'),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.schedule,
                  title: 'Programación',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/programacion'),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.radio_outlined,
                  title: 'Frecuencias',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/frecuencias'),
                ),

                _section('Síguenos'),
                _row(
                  icon: Icons.facebook,
                  title: 'Facebook',
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AppConfig.instance.facebookUrl),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.alternate_email,
                  title: 'X / Twitter',
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AppConfig.instance.twitterUrl),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.camera_alt_outlined,
                  title: 'Instagram',
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AppConfig.instance.instagramUrl),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.play_circle_outline,
                  title: 'YouTube',
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AppConfig.instance.youtubeUrl),
                ),

                _section('General'),
                _row(
                  icon: Icons.notifications_none,
                  title: 'Notificaciones',
                  trailing: Switch(
                    value: _notifsEnabled,
                    onChanged: _setNotifs,
                  ),
                  onTap: () => _setNotifs(!_notifsEnabled),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.lock_outline,
                  title: 'Política de privacidad',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/perfil/privacidad'),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.description_outlined,
                  title: 'Términos de uso',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/perfil/terminos'),
                ),

                _section('Información'),
                _row(
                  icon: Icons.info_outline,
                  title: 'Sobre la app',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'RadioTeleTaxi',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Radio Tele Taxi',
                  ),
                ),
                const Divider(height: 1),
                _row(
                  icon: Icons.article_outlined,
                  title: 'Licencias de código abierto',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'RadioTeleTaxi',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Radio Tele Taxi',
                  ),
                ),

                _section('Datos'),
                _row(
                  icon: Icons.delete_outline,
                  title: 'Eliminar mis datos',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _confirmDelete,
                  destructive: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Icon(icon, color: RttColors.red, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: destructive ? RttColors.red : null,
                  fontWeight: destructive ? FontWeight.w600 : FontWeight.w500,
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
