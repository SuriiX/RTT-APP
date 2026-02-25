import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';
import '../../widgets/rtt_scaffold.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final api = ApiClient();

  // Datos reales
  final String phoneNumber = '934661819';
  final String whatsappNumber = '34646212121';

  bool loading = true;
  List<dynamic> directo = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safeUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    return Uri.encodeFull(u);
  }

  Future<void> _load() async {
    try {
      final d = await api.getList(Endpoints.directo());
      await AudioController.instance.ensureInit(Endpoints.streamingUrl);

      setState(() {
        directo = d;
        loading = false;
      });

      final dm = _directoMap;
      final programa = (dm?['programa'] ?? 'Radio TeleTaxi').toString();
      AudioController.instance.setProgramTitle(programa);
    } catch (e) {
      debugPrint('Player load error: $e');
      setState(() => loading = false);
    }
  }

  Map<String, dynamic>? get _directoMap {
    if (directo.isNotEmpty && directo.first is Map) {
      return directo.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> _call() async {
    await launchUrl(Uri.parse('tel:$phoneNumber'), mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsapp() async {
    await launchUrl(Uri.parse('https://wa.me/$whatsappNumber'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final d = _directoMap;

    final horaIni = (d?['hora_inicio'] ?? '').toString();
    final horaFin = (d?['hora_fi_real'] ?? '').toString();
    final hora = (horaIni.isNotEmpty && horaFin.isNotEmpty) ? 'De $horaIni a $horaFin' : '';

    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    final presentador = (d?['presentador'] ?? '').toString();

    final imgPresentador = (d?['imagen_presentador'] ?? '').toString().trim();
    final coverFallback = Endpoints.cover();

    final avatarUrl = imgPresentador.isNotEmpty ? imgPresentador : coverFallback;

    return RttScaffold(
      title: 'RadioTeleTaxi',
      actions: [
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
        ),
      ],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
              child: Column(
                children: [
                  _avatar(avatarUrl),
                  const SizedBox(height: 18),

                  if (hora.isNotEmpty)
                    Text(
                      '$hora h',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 6),
                  Text(
                    programa,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),
                  if (presentador.trim().isNotEmpty)
                    Text(
                      presentador,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 22),

                  // Play/Pause grande sincronizado
                  AnimatedBuilder(
                    animation: AudioController.instance,
                    builder: (context, _) {
                      final ctrl = AudioController.instance;
                      final playing = ctrl.isPlaying;

                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => ctrl.toggle(),
                          icon: Icon(
                            playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: const Color(0xFFE53935),
                            size: 26,
                          ),
                          label: Text(
                            playing ? 'PAUSAR DIRECTO' : 'ESCUCHAR DIRECTO',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  _actionButton(
                    icon: Icons.phone,
                    text: 'Llamar en directo',
                    color: const Color(0xFF4A4A4A),
                    onTap: _call,
                  ),

                  _actionButton(
                    icon: Icons.chat,
                    text: 'Whatsapp',
                    color: const Color(0xFF25D366),
                    onTap: _openWhatsapp,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _avatar(String url) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE53935), width: 3),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: _safeUrl(url),
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 46, color: Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
