import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/favorites/favorites_service.dart';
import '../../widgets/rtt_error_widget.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';
import 'actualidad_repository.dart';
import 'noticia_model.dart';

class ActualidadDetallePage extends StatefulWidget {
  const ActualidadDetallePage({super.key, required this.postId});
  final String postId;

  @override
  State<ActualidadDetallePage> createState() => _ActualidadDetallePageState();
}

class _ActualidadDetallePageState extends State<ActualidadDetallePage> {
  late final ActualidadRepository repo;
  late Future<Noticia?> future;

  @override
  void initState() {
    super.initState();
    repo = ActualidadRepository();
    future = _loadById(widget.postId);
  }

  Future<Noticia?> _loadById(String id) async {
    final res = await repo.fetchActualidad(page: 1, perPage: 50);
    final targetId = int.tryParse(id) ?? -1;
    for (final n in res.news) {
      if (n.id == targetId) return n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Actualidad',
      actions: [
        AnimatedBuilder(
          animation: FavoritesService.instance,
          builder: (context, _) {
            final isFav = FavoritesService.instance.isFavorite(
                FavoriteType.noticia, widget.postId);
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFav),
                  color: isFav ? Colors.white : Colors.white70,
                ),
              ),
              tooltip: isFav ? 'Quitar de favoritos' : 'Guardar en favoritos',
              onPressed: () => FavoritesService.instance
                  .toggleFavorite(FavoriteType.noticia, widget.postId),
            );
          },
        ),
      ],
      body: FutureBuilder<Noticia?>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const RttShimmerDetail();
          }
          if (snap.hasError) {
            return RttErrorWidget(
              message: snap.error.toString(),
              onRetry: () => setState(() { future = _loadById(widget.postId); }),
            );
          }
          final n = snap.data;
          if (n == null) {
            return const Center(child: Text('No se encontró la noticia'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() { future = _loadById(widget.postId); });
              await future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              children: [
                if (n.featuredImage.isNotEmpty)
                  Hero(
                    tag: 'actualidad-img-${widget.postId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: n.featuredImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(height: 200, color: Colors.black12),
                        errorWidget: (_, __, ___) => Container(height: 200, color: Colors.black12),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  n.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  n.date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // HTML WordPress
                Html(data: n.content),
              ],
            ),
          );
        },
      ),
    );
  }
}
