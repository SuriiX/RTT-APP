import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/rtt_scaffold.dart';
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

  final List<Noticia> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;

  static const int _perPage = 10;

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
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Actualidad',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFirst,
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                itemCount: _items.length + (_loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  if (_loadingMore && i == _items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final n = _items[i];
                  return _NewsCard(
                    noticia: n,
                    onTap: () => context.push('/actualidad/${n.id}'),
                  );
                },
              ),
            ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.noticia, required this.onTap});

  final Noticia noticia;
  final VoidCallback onTap;

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
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  noticia.featuredImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 140),
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
                            color: Colors.red,
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
                  Text(
                    noticia.date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
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
