import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final api = ApiClient();

  // Datos reales
  final String phoneNumber = '934661819';
  final String whatsappNumber = '34645212121';

  bool loading = true;
  bool liked = false;

  Map<String, dynamic>? settings;
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
      final s = await api.getMap(Endpoints.settings());
      final d = await api.getList(Endpoints.directo());

      final url = (s['streaming']?['url'] as String?) ?? '';
      await AudioController.instance.ensureInit(url);

      setState(() {
        settings = s;
        directo = d;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Player load error: $e');
    }
  }

  Future<void> _call() async {
    await launchUrl(Uri.parse('tel:$phoneNumber'), mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsapp() async {
    await launchUrl(Uri.parse('https://wa.me/$whatsappNumber'), mode: LaunchMode.externalApplication);
  }

  // (Sin share_plus por ahora) -> placeholder
  void _sharePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartir: pendiente')),
    );
  }

  Map<String, dynamic>? get _directoMap {
    if (directo.isNotEmpty && directo.first is Map) return directo.first as Map<String, dynamic>;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final d = _directoMap;

    final hora = '${d?['hora_inicio'] ?? ''} a ${d?['hora_fi_real'] ?? ''}'.trim();
    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    final presentador = (d?['presentador'] ?? '').toString();

    final imgPresentador = (d?['imagen_presentador'] ?? '').toString().trim();
    final coverFallback = (settings?['streaming']?['cover'] ?? Endpoints.cover()).toString();

    final avatarUrl = imgPresentador.isNotEmpty ? imgPresentador : coverFallback;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _topBar(context),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 28, 18, 90),
                        child: Column(
                          children: [
                            _avatar(avatarUrl),
                            const SizedBox(height: 18),

                            if (hora.replaceAll('a', '').trim().isNotEmpty)
                              Text(
                                'De $hora h',
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
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                            const SizedBox(height: 22),

                            // Botón play/pause grande (no estaba muy explícito en la captura,
                            // pero es clave para UX)
                            AnimatedBuilder(
                              animation: AudioController.instance,
                              builder: (context, _) {
                                final playing = AudioController.instance.isPlaying;
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
                                    onPressed: () => AudioController.instance.toggle(),
                                    icon: Icon(
                                      playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                      color: const Color(0xFFE53935),
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

                            // Acciones (igual a tu captura)
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
              ),
            ],
          ),

          // Mini-player fijo abajo (como en Home)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _miniPlayer(programa),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      height: 56,
      color: const Color(0xFFE53935),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Abre el drawer del Scaffold padre (Shell)
              Scaffold.of(context).openDrawer();
            },
          ),
          const SizedBox(width: 6),

          // Logo circular (placeholder)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: const Text('RTT', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'RadioTeleTaxi',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: Colors.white),
            onPressed: () => setState(() => liked = !liked),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: _sharePlaceholder,
          ),
        ],
      ),
    );
  }

  Widget _avatar(String url) {
    return Container(
      width: 130,
      height: 130,
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

  Widget _miniPlayer(String programa) {
    return AnimatedBuilder(
      animation: AudioController.instance,
      builder: (context, _) {
        final ctrl = AudioController.instance;
        final playing = ctrl.isPlaying;

        return Material(
          elevation: 10,
          child: Container(
            height: 64,
            color: const Color(0xFFE53935),
            child: Row(
              children: [
                InkWell(
                  onTap: () => ctrl.toggle(),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFFB71C1C),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ESCÚCHANOS EN DIRECTO',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(programa, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
