import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/audio/audio_controller.dart';
import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_scaffold.dart';
import 'alacarta_repository.dart';
import 'models.dart';

/// Detalle de un Show (podcast o radioshow) — replica el mockup de
/// "Las Entrevistas de RTT": imagen grande, descripción, botón
/// "ESCUCHAR PROGRAMA", botón favorito y lista de episodios.
class ShowDetailPage extends StatefulWidget {
  const ShowDetailPage({super.key, required this.showId});
  final String showId;

  @override
  State<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends State<ShowDetailPage> {
  final _repo = AlaCartaRepository.instance;
  late Future<_ShowDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ShowDetail> _load() async {
    final show = await _repo.fetchShowById(widget.showId);
    final episodes = await _repo.fetchEpisodesOfShow(widget.showId);
    return _ShowDetail(show: show, episodes: episodes);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Programa',
      showBackButton: true,
      body: FutureBuilder<_ShowDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (data?.show == null) {
            return const _NotAvailable();
          }
          return _Body(show: data!.show!, episodes: data.episodes);
        },
      ),
    );
  }
}

class _ShowDetail {
  const _ShowDetail({required this.show, required this.episodes});
  final AlaCartaShow? show;
  final List<AlaCartaEpisode> episodes;
}

class _Body extends StatelessWidget {
  const _Body({required this.show, required this.episodes});
  final AlaCartaShow show;
  final List<AlaCartaEpisode> episodes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 140,
                height: 140,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Radio TeleTaxi',
                    style: TextStyle(
                      color: RttColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (show.description.isNotEmpty) ...[
          Text(
            show.description,
            style: const TextStyle(
                fontSize: 15, height: 1.4, color: Colors.black87),
          ),
          const SizedBox(height: 18),
        ],

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: episodes.isEmpty
                    ? null
                    : () async {
                        // Reproduce el episodio más reciente (primer item).
                        final ep = episodes.first;
                        final ctrl = AudioController.instance;
                        try {
                          await ctrl.ensureInit(
                            ep.audioUrl,
                            title: ep.title.isNotEmpty ? ep.title : show.title,
                          );
                          await ctrl.play();
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No se pudo reproducir: $e')),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: RttColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'ESCUCHAR PROGRAMA',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: FavoritesService.instance,
              builder: (context, _) {
                final isFav = FavoritesService.instance.isFavorite(
                    FavoriteType.evento, 'show-${show.id}');
                return IconButton.outlined(
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Colors.black26),
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? RttColors.red : Colors.black54,
                  ),
                  onPressed: () => FavoritesService.instance.toggleFavorite(
                    FavoriteType.evento,
                    'show-${show.id}',
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 26),
        const Row(
          children: [
            Text(
              'EPISODIOS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Spacer(),
            Text(
              'Más recientes',
              style: TextStyle(color: RttColors.red, fontWeight: FontWeight.w700),
            ),
            Icon(Icons.expand_more, color: RttColors.red),
          ],
        ),
        const Divider(height: 24),

        if (episodes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Aún no hay episodios disponibles.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          )
        else
          for (final ep in episodes) _EpisodeRow(episode: ep),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.episode});
  final AlaCartaEpisode episode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: episode.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: episode.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _x, _y) =>
                          Container(color: RttColors.red),
                    )
                  : Container(color: RttColors.red),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      episode.formattedDate,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    if (episode.formattedDuration.isNotEmpty) ...[
                      const Icon(Icons.access_time,
                          size: 13, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        episode.formattedDuration,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill,
                size: 34, color: RttColors.red),
            tooltip: 'Reproducir episodio',
            onPressed: episode.audioUrl.isEmpty
                ? null
                : () async {
                    final ctrl = AudioController.instance;
                    final label = episode.title.isNotEmpty
                        ? episode.title
                        : episode.showTitle;
                    try {
                      await ctrl.ensureInit(episode.audioUrl, title: label);
                      await ctrl.play();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo reproducir: $e')),
                      );
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Text(
          'Este programa todavía no está disponible.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }
}
