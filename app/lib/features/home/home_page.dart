import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_error_widget.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';
import 'home_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = HomeRepository();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAll();
    _future.then(_onLoaded).catchError((_) {});
    _initPlayer();
    AudioController.instance.attach();
  }

  Future<_HomeData> _loadAll() async {
    final results = await Future.wait([
      _repo.fetchDirecto(),
      _repo.fetchActualidadTop(perPage: 6),
      _repo.fetchEventosTop(max: 8),
    ]);
    return _HomeData(
      directo: results[0],
      actualidad: results[1],
      eventos: results[2],
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadAll());
    _future.then(_onLoaded).catchError((_) {});
    await _future;
  }

  void _onLoaded(_HomeData data) {
    if (!mounted) return;
    final d = (data.directo.isNotEmpty && data.directo.first is Map)
        ? data.directo.first as Map
        : null;
    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    if (programa.trim().isNotEmpty) {
      AudioController.instance.setProgramTitle(programa);
    }
  }

  Future<void> _initPlayer() async {
    try {
      await AudioController.instance.ensureInit(Endpoints.streamAndroid());
    } catch (e) {
      debugPrint('Init player error: $e');
    }
  }

  String _safeUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    return Uri.encodeFull(u);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'RadioTeleTaxi',
      body: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const RttShimmerHome();
          }
          if (snap.hasError) {
            return RttErrorWidget(
              message: snap.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snap.data ??
              const _HomeData(directo: [], actualidad: [], eventos: []);
          final d = (data.directo.isNotEmpty && data.directo.first is Map)
              ? (data.directo.first as Map)
              : null;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              children: [
                _hero(context, d),
                const SizedBox(height: 24),
                _ActualidadCarousel(items: data.actualidad),
                const SizedBox(height: 24),
                _EntradasCarousel(items: data.eventos),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- HERO ----------

  Widget _hero(BuildContext context, Map? d) {
    final heroImage = (() {
      final a = (d?['imagen_app_programa'] ?? '').toString().trim();
      if (a.isNotEmpty) return a;
      final b = (d?['imagen_reproductor_web'] ?? '').toString().trim();
      if (b.isNotEmpty) return b;
      return Endpoints.cover();
    })();

    final programa = (d?['programa'] ?? 'Radio TeleTaxi').toString();
    final presentador = (d?['presentador'] ?? '').toString();
    final horaIni = (d?['hora_inicio'] ?? '').toString();
    final horaFin = (d?['hora_fi_real'] ?? '').toString();
    final hora = (horaIni.isNotEmpty && horaFin.isNotEmpty)
        ? 'De $horaIni a $horaFin'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 1,
              child: heroImage.isEmpty
                  ? Container(color: RttColors.red)
                  : CachedNetworkImage(
                      imageUrl: _safeUrl(heroImage),
                      fit: BoxFit.cover,
                      errorWidget: (_, _x, _y) =>
                          Container(color: RttColors.red),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            programa,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.1,
            ),
          ),
          if (presentador.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Con $presentador',
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
          if (hora.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 16, color: RttColors.red),
                const SizedBox(width: 6),
                Text(
                  '$hora h',
                  style: const TextStyle(
                      color: RttColors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Carrusel Actualidad ────────────────────────────────────────────────────

class _ActualidadCarousel extends StatelessWidget {
  const _ActualidadCarousel({required this.items});
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'ACTUALIDAD',
          onSeeAll: () => context.push('/actualidad'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _x) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final m = items[i] is Map ? items[i] as Map : <String, dynamic>{};
              final id = (m['id'] ?? '').toString();
              final title = _strip(m['title'] ?? '');
              final image = (m['featured_image'] ?? '').toString();
              return _RoundCarouselItem(
                imageUrl: image,
                title: title,
                onTap: () {
                  if (id.isNotEmpty) {
                    context.push('/actualidad/$id');
                  } else {
                    context.push('/actualidad');
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _strip(dynamic raw) =>
      raw.toString().replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

class _RoundCarouselItem extends StatelessWidget {
  const _RoundCarouselItem({
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: SizedBox(
                width: 110,
                height: 110,
                child: imageUrl.isEmpty
                    ? Container(color: Colors.black12)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _x, _y) =>
                            Container(color: Colors.black12),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carrusel Entradas a la venta ───────────────────────────────────────────

class _EntradasCarousel extends StatelessWidget {
  const _EntradasCarousel({required this.items});
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'ENTRADAS A LA VENTA',
          onSeeAll: () => context.go('/entradas'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _x) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final m = items[i] is Map ? items[i] as Map : <String, dynamic>{};
              final id = (m['id'] ?? '').toString();
              final title = (m['title'] ?? '').toString();
              final image = (m['featured_image'] ?? '').toString();
              return _SquareCarouselItem(
                imageUrl: image,
                title: title,
                onTap: () {
                  if (id.isNotEmpty) {
                    context.push('/eventos/$id');
                  } else {
                    context.go('/entradas');
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SquareCarouselItem extends StatelessWidget {
  const _SquareCarouselItem({
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl.isEmpty
                    ? Container(color: Colors.black12)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _x, _y) =>
                            Container(color: Colors.black12),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: RttColors.red,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.4,
              ),
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'VER MÁS',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.directo,
    required this.actualidad,
    required this.eventos,
  });

  final List<dynamic> directo;
  final List<dynamic> actualidad;
  final List<dynamic> eventos;
}
