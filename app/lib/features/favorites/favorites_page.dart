import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_scaffold.dart';
import '../actualidad/actualidad_repository.dart';
import '../actualidad/noticia_model.dart';
import '../eventos/evento_model.dart';
import '../eventos/eventos_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _actualidadRepo = ActualidadRepository();
  final _eventosRepo = EventosRepository();
  final _favs = FavoritesService.instance;

  List<Noticia> _noticias = [];
  List<Evento> _eventos = [];
  bool _loadingNoticias = false;
  bool _loadingEventos = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadAll();
    _favs.addListener(_onFavsChanged);
  }

  @override
  void dispose() {
    _favs.removeListener(_onFavsChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onFavsChanged() {
    // Reload when favorites change (e.g. removed from this page)
    _loadAll();
  }

  Future<void> _loadAll() async {
    _loadNoticias();
    _loadEventos();
  }

  Future<void> _loadNoticias() async {
    final ids = _favs.getFavorites(FavoriteType.noticia);
    if (ids.isEmpty) {
      if (mounted) setState(() => _noticias = []);
      return;
    }

    if (mounted) setState(() => _loadingNoticias = true);

    try {
      // Fetch a large batch and filter by saved IDs
      final res = await _actualidadRepo.fetchActualidad(page: 1, perPage: 50);
      final idSet = ids.toSet();
      final filtered = res.news
          .where((n) => idSet.contains(n.id.toString()))
          .toList();
      if (mounted) setState(() => _noticias = filtered);
    } catch (_) {
      // Keep current list on error
    } finally {
      if (mounted) setState(() => _loadingNoticias = false);
    }
  }

  Future<void> _loadEventos() async {
    final ids = _favs.getFavorites(FavoriteType.evento);
    if (ids.isEmpty) {
      if (mounted) setState(() => _eventos = []);
      return;
    }

    if (mounted) setState(() => _loadingEventos = true);

    try {
      final all = await _eventosRepo.fetchEventos();
      final idSet = ids.toSet();
      final filtered = all.where((e) => idSet.contains(e.id)).toList();
      if (mounted) setState(() => _eventos = filtered);
    } catch (_) {
      // Keep current list on error
    } finally {
      if (mounted) setState(() => _loadingEventos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Favoritos',
      body: Column(
        children: [
          Material(
            color: Colors.white,
            elevation: 1,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: RttColors.red,
              unselectedLabelColor: Colors.black54,
              indicatorColor: RttColors.red,
              tabs: [
                Tab(
                  text: 'Noticias (${_favs.noticiaIds.length})',
                ),
                Tab(
                  text: 'Eventos (${_favs.eventoIds.length})',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _noticiasTab(),
                _eventosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticiasTab() {
    if (_loadingNoticias && _noticias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_noticias.isEmpty) {
      return _emptyState(
        icon: Icons.newspaper_outlined,
        text: 'No tienes noticias favoritas',
        subtitle: 'Toca el corazón en una noticia para guardarla aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNoticias(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _noticias.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final n = _noticias[i];
          return _FavNoticiaCard(
            noticia: n,
            onTap: () => context.push('/actualidad/${n.id}'),
            onRemove: () =>
                _favs.removeFavorite(FavoriteType.noticia, n.id.toString()),
          );
        },
      ),
    );
  }

  Widget _eventosTab() {
    if (_loadingEventos && _eventos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_eventos.isEmpty) {
      return _emptyState(
        icon: Icons.calendar_month_outlined,
        text: 'No tienes eventos favoritos',
        subtitle: 'Toca el corazón en un evento para guardarlo aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadEventos(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _eventos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final e = _eventos[i];
          return _FavEventoCard(
            evento: e,
            onTap: () => context.push('/eventos/${e.id}'),
            onRemove: () =>
                _favs.removeFavorite(FavoriteType.evento, e.id),
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String text,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Cards ----------

class _FavNoticiaCard extends StatelessWidget {
  const _FavNoticiaCard({
    required this.noticia,
    required this.onTap,
    required this.onRemove,
  });

  final Noticia noticia;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (noticia.featuredImage.isNotEmpty)
              SizedBox(
                width: 100,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl: noticia.featuredImage,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noticia.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noticia.date,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: RttColors.red),
              onPressed: onRemove,
              tooltip: 'Quitar de favoritos',
            ),
          ],
        ),
      ),
    );
  }
}

class _FavEventoCard extends StatelessWidget {
  const _FavEventoCard({
    required this.evento,
    required this.onTap,
    required this.onRemove,
  });

  final Evento evento;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dd = evento.date.day.toString().padLeft(2, '0');
    final mm = evento.date.month.toString().padLeft(2, '0');
    final yyyy = evento.date.year.toString();

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (evento.imageUrl.isNotEmpty)
              SizedBox(
                width: 100,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl: evento.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dd/$mm/$yyyy',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: RttColors.red),
              onPressed: onRemove,
              tooltip: 'Quitar de favoritos',
            ),
          ],
        ),
      ),
    );
  }
}
