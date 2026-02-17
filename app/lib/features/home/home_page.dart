import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiClient();
  late Future<Map<String, dynamic>> future;

  // Datos reales
  final String phoneNumber = '934661819';
  final String whatsappNumber = '34645212121'; // +34 646 21 21 21 (sin + ni espacios)

  @override
  void initState() {
    super.initState();
    future = api.getMap(Endpoints.home());
    _autoStartPlayer();
  }

  // En Android/iOS iniciará; en Web puede fallar por política de autoplay del navegador.
  Future<void> _autoStartPlayer() async {
    try {
      final settings = await api.getMap(Endpoints.settings());
      final url = (settings['streaming']?['url'] as String?) ?? '';
      await AudioController.instance.ensureInit(url);
      await AudioController.instance.play();
    } catch (e) {
      debugPrint('Autoplay error: $e');
    }
  }

  Future<void> _openWhatsapp() async {
    final uri = Uri.parse('https://wa.me/$whatsappNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _safeUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    return Uri.encodeFull(u);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text('RadioTeleTaxi'),
        actions: [
          IconButton(
            tooltip: 'Llamar',
            icon: const Icon(Icons.phone),
            onPressed: () => launchUrl(Uri.parse('tel:$phoneNumber'), mode: LaunchMode.externalApplication),
          ),
          IconButton(
            tooltip: 'Directo',
            icon: const Icon(Icons.play_circle_fill),
            onPressed: () => context.go('/player'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data ?? {};
          final directo = data['directo'];
          final actualidad = data['actualidad'];

          final d = (directo is List && directo.isNotEmpty) ? (directo.first as Map) : null;

          // Imagen del hero (prioriza imagen_app_programa, luego imagen_reproductor_web, luego cover)
          final heroImage = (() {
            final a = (d?['imagen_app_programa'] ?? '').toString().trim();
            if (a.isNotEmpty) return a;
            final b = (d?['imagen_reproductor_web'] ?? '').toString().trim();
            if (b.isNotEmpty) return b;
            return Endpoints.cover();
          })();

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  _hero(context, d, heroImage),

                  _actionButton(
                    icon: Icons.phone,
                    text: 'Llamar en directo',
                    color: const Color(0xFF4A4A4A),
                    onTap: () => launchUrl(Uri.parse('tel:$phoneNumber'), mode: LaunchMode.externalApplication),
                  ),

                  _actionButton(
                    icon: Icons.chat,
                    text: 'Whatsapp',
                    color: const Color(0xFF25D366),
                    onTap: _openWhatsapp,
                  ),

                  _actionButton(
                    icon: Icons.schedule,
                    text: 'Ver programación',
                    color: const Color(0xFFE53935),
                    onTap: () => context.go('/programacion'),
                  ),

                  _actionButton(
                    icon: Icons.confirmation_num_outlined,
                    text: 'Entradas',
                    color: const Color(0xFF6BB6FF),
                    onTap: () => context.go('/entradas'),
                  ),

                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'ACTUALIDAD',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _newsList(actualidad),

                  const SizedBox(height: 90), // espacio para el mini-player
                ],
              ),

              Positioned(left: 0, right: 0, bottom: 0, child: _miniPlayer(d)),
            ],
          );
        },
      ),
    );
  }

  Widget _hero(BuildContext context, Map? d, String imageUrl) {
    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    final hora = '${d?['hora_inicio'] ?? ''} - ${d?['hora_fi_real'] ?? ''}'.trim();
    final pres = (d?['presentador'] ?? '').toString();

    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _safeUrl(imageUrl),
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.black12),
          ),
          Container(color: const Color(0xAAE53935)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                if (hora.replaceAll('-', '').trim().isNotEmpty)
                  Text(hora, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  programa,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pres.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Con $pres', style: const TextStyle(color: Colors.white)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => context.go('/player'),
                  child: const Text(
                    'PROGRAMA EN DIRECTO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsList(dynamic actualidad) {
    final news = (actualidad is Map && actualidad['news'] is List)
        ? (actualidad['news'] as List)
        : <dynamic>[];

    if (news.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Sin noticias disponibles'),
      );
    }

    return ListView.builder(
      itemCount: news.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) {
        final n = news[i] as Map;
        final img = (n['featured_image'] ?? '').toString();
        final title = (n['title'] ?? '').toString();
        final excerpt = (n['excerpt'] ?? '').toString();
        final date = (n['date'] ?? '').toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (img.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      _safeUrl(img),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        debugPrint('❌ Imagen no carga: $img | $error');
                        return Container(
                          height: 180,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DESTACADAS',
                        style: TextStyle(color: Color(0xFFE53935), fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(excerpt),
                      const SizedBox(height: 8),
                      Text(date, style: const TextStyle(color: Colors.black54)),
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

  Widget _miniPlayer(Map? d) {
    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();

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
                  child: InkWell(
                    onTap: () => context.go('/player'),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
