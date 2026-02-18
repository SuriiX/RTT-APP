import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';
import '../../widgets/rtt_scaffold.dart';

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
  final String whatsappNumber = '34646212121';

  @override
  void initState() {
    super.initState();
    future = api.getMap(Endpoints.home());
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final settings = await api.getMap(Endpoints.settings());
      final url = (settings['streaming']?['url'] as String?) ?? '';
      await AudioController.instance.ensureInit(url);

      // Autoplay: solo nativo (web suele bloquear autoplay)
      if (!kIsWeb) {
        await AudioController.instance.play();
      }
    } catch (e) {
      debugPrint('Init player error: $e');
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

  /// Imagen PRO:
  /// - Fondo: cover (llena, sirve de “cover”)
  /// - Encima: contain (imagen completa sin recorte)
  /// - Overlay suave para que no se vea “cruda”
  Widget _proImage({
    required String url,
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    final u = _safeUrl(url);

    Widget img = SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo (cover)
          CachedNetworkImage(
            imageUrl: u,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.black12),
          ),
          // Overlay suave (simula blur/estilo)
          Container(color: Colors.black.withOpacity(0.18)),
          // Imagen real (contain, sin recortar)
          Center(
            child: CachedNetworkImage(
              imageUrl: u,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ],
      ),
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius, child: img);
    }
    return img;
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'RadioTeleTaxi',
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

          // Título en mini-player
          final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
          AudioController.instance.setProgramTitle(programa);

          // Hero image (prioriza ACF app -> fondo reproductor -> cover)
          final heroImage = (() {
            final a = (d?['imagen_app_programa'] ?? '').toString().trim();
            if (a.isNotEmpty) return a;
            final b = (d?['imagen_reproductor_web'] ?? '').toString().trim();
            if (b.isNotEmpty) return b;
            return Endpoints.cover();
          })();

          return ListView(
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

              const SizedBox(height: 20),
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

    // ✅ Más altura (estirado en vertical)
    const heroHeight = 380.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ PRO image: fondo cover + imagen contain (sin recorte)
          _proImage(
            url: imageUrl,
            height: heroHeight,
          ),

          // overlay rojo como la app
          Container(color: const Color(0x88E53935)),

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
          ),
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
                  _proImage(
                    url: img,
                    height: 220, // ✅ más alto que antes
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
}
