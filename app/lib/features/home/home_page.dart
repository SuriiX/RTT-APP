import 'dart:async';
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

  String _lastProgramTitle = '';

  @override
  void initState() {
    super.initState();
    future = api.getMap(Endpoints.home());
    _initPlayer();
    AudioController.instance.attach(); // importante para audio_service
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
  /// - Fondo: cover (llena)
  /// - Encima: contain (imagen completa sin recorte)
  /// - Overlay suave
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
          CachedNetworkImage(
            imageUrl: u,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.black12),
          ),
          Container(color: Colors.black.withOpacity(0.18)),
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
          onPressed: () => launchUrl(Uri.parse('tel:$phoneNumber'),
              mode: LaunchMode.externalApplication),
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

          final d = (directo is List && directo.isNotEmpty)
              ? (directo.first as Map)
              : null;

          final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
          if (programa.trim().isNotEmpty && programa != _lastProgramTitle) {
            _lastProgramTitle = programa;
            // No lo hagas en build directamente sin control
            scheduleMicrotask(() => AudioController.instance.setProgramTitle(programa));
          }

          final heroImage = (() {
            final a = (d?['imagen_app_programa'] ?? '').toString().trim();
            if (a.isNotEmpty) return a;
            final b = (d?['imagen_reproductor_web'] ?? '').toString().trim();
            if (b.isNotEmpty) return b;
            return Endpoints.cover();
          })();

          return ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              _hero(context, d, heroImage),

              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle('ACCESOS RÁPIDOS'),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _quickActions(context),
              ),

              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: _headlineRed('ACTUALIDAD')),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _newsList(actualidad),
              ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _headlineRed(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE53935),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _actionTile(
          icon: Icons.phone,
          title: 'Llamar',
          subtitle: 'En directo',
          onTap: () => launchUrl(Uri.parse('tel:$phoneNumber'),
              mode: LaunchMode.externalApplication),
        ),
        _actionTile(
          icon: Icons.chat,
          title: 'WhatsApp',
          subtitle: 'Escríbenos',
          onTap: _openWhatsapp,
        ),
        _actionTile(
          icon: Icons.schedule,
          title: 'Programación',
          subtitle: 'Ver horarios',
          onTap: () => context.go('/programacion'),
        ),
        _actionTile(
          icon: Icons.confirmation_num_outlined,
          title: 'Entradas',
          subtitle: 'Comprar',
          onTap: () => context.go('/entradas'),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFE53935)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- HERO ----------

  Widget _hero(BuildContext context, Map? d, String imageUrl) {
    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    final hora = '${d?['hora_inicio'] ?? ''} - ${d?['hora_fi_real'] ?? ''}'.trim();
    final pres = (d?['presentador'] ?? '').toString();

    const heroHeight = 380.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _proImage(url: imageUrl, height: heroHeight),

          // overlay rojo
          Container(color: const Color(0x88E53935)),

          SafeArea(
            child: Padding(
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
                      height: 1.05,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ),
        ],
      ),
    );
  }

  // ---------- NEWS LIST ----------

  Widget _newsList(dynamic actualidad) {
    final news = (actualidad is Map && actualidad['news'] is List)
        ? (actualidad['news'] as List)
        : <dynamic>[];

    if (news.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Sin noticias disponibles'),
      );
    }

    return ListView.separated(
      itemCount: news.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final n = news[i] as Map;

        final id = (n['id'] ?? '').toString();
        final img = (n['featured_image'] ?? '').toString();
        final category = (n['category'] ?? 'DESTACADAS').toString();
        final title = (n['title'] ?? '').toString();
        final excerpt = (n['excerpt'] ?? '').toString();
        final date = (n['date'] ?? '').toString();

        return Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (id.trim().isNotEmpty) {
                context.push('/actualidad/$id');
              } else {
                context.go('/actualidad');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (img.trim().isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image(
                      image: CachedNetworkImageProvider(_safeUrl(img)),
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _stripHtml(excerpt),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
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

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
