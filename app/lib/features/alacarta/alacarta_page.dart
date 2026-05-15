import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_scaffold.dart';
import 'alacarta_repository.dart';
import 'models.dart';

enum _Filter { all, podcasts, u7d }

/// Pantalla "A la carta": replicará exactamente el plugin de WP
/// `radioteletaxi.com/a-la-carta` cuando el backend exponga endpoints
/// públicos. Mientras tanto enseña estado vacío explícito al usuario.
class AlaCartaPage extends StatefulWidget {
  const AlaCartaPage({super.key});

  @override
  State<AlaCartaPage> createState() => _AlaCartaPageState();
}

class _AlaCartaPageState extends State<AlaCartaPage> {
  final _repo = AlaCartaRepository.instance;
  _Filter _filter = _Filter.all;

  late Future<_AlaCartaData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AlaCartaData> _load() async {
    final results = await Future.wait([
      _repo.fetchPodcasts(),
      _repo.fetchU7D(),
    ]);
    return _AlaCartaData(podcasts: results[0], u7d: results[1]);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'A la carta',
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_AlaCartaData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? const _AlaCartaData(podcasts: [], u7d: []);
            return _Body(
              data: data,
              filter: _filter,
              onFilter: (f) => setState(() => _filter = f),
              backendOnline: _repo.isBackendOnline,
            );
          },
        ),
      ),
    );
  }
}

class _AlaCartaData {
  const _AlaCartaData({required this.podcasts, required this.u7d});
  final List<AlaCartaShow> podcasts;
  final List<AlaCartaShow> u7d;
}

class _Body extends StatelessWidget {
  const _Body({
    required this.data,
    required this.filter,
    required this.onFilter,
    required this.backendOnline,
  });

  final _AlaCartaData data;
  final _Filter filter;
  final ValueChanged<_Filter> onFilter;
  final bool backendOnline;

  bool get _showPodcasts => filter == _Filter.all || filter == _Filter.podcasts;
  bool get _showU7d => filter == _Filter.all || filter == _Filter.u7d;

  @override
  Widget build(BuildContext context) {
    final isEmpty = data.podcasts.isEmpty && data.u7d.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      children: [
        // Header
        Text(
          'A LA CARTA',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Escucha cuando quieras',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Filtros
        Row(
          children: [
            _FilterChip(
              label: 'Todo',
              selected: filter == _Filter.all,
              onTap: () => onFilter(_Filter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Podcasts',
              selected: filter == _Filter.podcasts,
              onTap: () => onFilter(_Filter.podcasts),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'U7D',
              selected: filter == _Filter.u7d,
              onTap: () => onFilter(_Filter.u7d),
            ),
          ],
        ),
        const SizedBox(height: 22),

        if (isEmpty)
          _EmptyState(backendOnline: backendOnline)
        else ...[
          if (_showPodcasts && data.podcasts.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.podcasts,
              title: 'PODCAST / ENTREVISTAS',
              onSeeAll: () => onFilter(_Filter.podcasts),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: data.podcasts.length,
                separatorBuilder: (_, _x) => const SizedBox(width: 14),
                itemBuilder: (context, i) => _PodcastCard(show: data.podcasts[i]),
              ),
            ),
            const SizedBox(height: 22),
          ],
          if (_showU7d && data.u7d.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.history,
              title: 'U7D (PROGRAMAS COMPLETOS)',
              onSeeAll: () => onFilter(_Filter.u7d),
            ),
            const SizedBox(height: 12),
            for (final show in data.u7d) _U7dRow(show: show),
          ],
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? RttColors.red : Colors.white;
    final fg = selected ? Colors.white : Colors.black87;
    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? RttColors.red : Colors.black26),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.onSeeAll,
  });

  final IconData icon;
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RttColors.red, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: RttColors.red,
              fontWeight: FontWeight.w800,
              fontSize: 15,
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
    );
  }
}

class _PodcastCard extends StatelessWidget {
  const _PodcastCard({required this.show});
  final AlaCartaShow show;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => context.push('/alacarta/show/${show.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (show.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: show.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _x, _y) =>
                            Container(color: RttColors.red),
                      )
                    else
                      Container(color: RttColors.red),
                    const Positioned(
                      right: 8,
                      bottom: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: RttColors.red,
                        child: Icon(Icons.mic, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              show.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              show.isPodcast ? 'Entrevista' : show.type,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _U7dRow extends StatelessWidget {
  const _U7dRow({required this.show});
  final AlaCartaShow show;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/alacarta/show/${show.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: show.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: show.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, _x, _y) =>
                                Container(color: RttColors.red),
                          )
                        : Container(color: RttColors.red),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        show.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        show.description.isEmpty
                            ? 'Programa completo'
                            : show.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_fill,
                      size: 38, color: RttColors.red),
                  onPressed: () => context.push('/alacarta/show/${show.id}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.backendOnline});
  final bool backendOnline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.headphones, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            backendOnline
                ? 'Próximamente'
                : 'Servicio no disponible',
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Los podcasts y los programas de los últimos 7 días se mostrarán '
              'aquí en cuanto la radio active esta sección.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
