import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_animated_list_item.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';
import 'actualidad_repository.dart';
import 'noticia_model.dart';

class ActualidadPage extends StatefulWidget {
  const ActualidadPage({super.key});

  @override
  State<ActualidadPage> createState() => _ActualidadPageState();
}

class _ActualidadPageState extends State<ActualidadPage> {
  late final ActualidadRepository repo;

  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  final List<Noticia> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  static const int _perPage = 10;

  List<Noticia> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.excerpt.toLowerCase().contains(q) ||
            n.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    repo = ActualidadRepository();

    _loadFirst();

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _items.clear();
      _page = 1;
      _totalPages = 1;
    });

    try {
      final res = await repo.fetchActualidad(page: 1, perPage: _perPage);
      setState(() {
        _items.addAll(res.news);
        _totalPages = res.totalPages;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore) return;
    if (_page >= _totalPages) return;

    setState(() => _loadingMore = true);

    try {
      final next = _page + 1;
      final res = await repo.fetchActualidad(page: next, perPage: _perPage);
      setState(() {
        _page = next;
        _items.addAll(res.news);
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Actualidad',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar noticias...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const RttShimmerList()
                : RefreshIndicator(
                    onRefresh: _loadFirst,
                    child: ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      itemCount:
                          _filteredItems.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        if (_loadingMore && i == _filteredItems.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child:
                                Center(child: CircularProgressIndicator()),
                          );
                        }

                        final n = _filteredItems[i];
                        return RttAnimatedListItem(
                          index: i,
                          child: AnimatedBuilder(
                          animation: FavoritesService.instance,
                          builder: (context, _) {
                            final isFav = FavoritesService.instance.isFavorite(
                              FavoriteType.noticia, n.id.toString());
                            return _NewsCard(
                              noticia: n,
                              onTap: () => context.push('/actualidad/${n.id}'),
                              isFav: isFav,
                              onToggleFav: () => FavoritesService.instance
                                  .toggleFavorite(FavoriteType.noticia, n.id.toString()),
                            );
                          },
                        ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.noticia, required this.onTap, required this.onToggleFav, required this.isFav});

  final Noticia noticia;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;
  final bool isFav;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (noticia.featuredImage.isNotEmpty)
              Hero(
                tag: 'actualidad-img-${noticia.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: noticia.featuredImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 140, color: Colors.black12),
                    errorWidget: (_, __, ___) => Container(height: 140, color: Colors.black12),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (noticia.category.isNotEmpty)
                    Text(
                      noticia.category.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: RttColors.red,
                            letterSpacing: 0.8,
                          ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    noticia.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stripHtml(noticia.excerpt),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          noticia.date,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onToggleFav,
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? RttColors.red : Colors.black38,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String input) {
    // tu API ya mete excerpt limpio casi siempre, pero por si viene con tags:
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
