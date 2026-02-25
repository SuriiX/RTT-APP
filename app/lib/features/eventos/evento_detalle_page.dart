import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/favorites/favorites_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_error_widget.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';
import 'evento_model.dart';
import 'eventos_repository.dart';
import 'eventos_share.dart';

class EventoDetallePage extends StatefulWidget {
  const EventoDetallePage({super.key, required this.eventId});
  final String eventId;

  @override
  State<EventoDetallePage> createState() => _EventoDetallePageState();
}

class _EventoDetallePageState extends State<EventoDetallePage> {
  late final EventosRepository repo;
  late Future<Evento> future;

  @override
  void initState() {
    super.initState();
    repo = EventosRepository();
    future = repo.fetchEventoById(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Evento',
      actions: [
        AnimatedBuilder(
          animation: FavoritesService.instance,
          builder: (context, _) {
            final isFav = FavoritesService.instance.isFavorite(
                FavoriteType.evento, widget.eventId);
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
                  .toggleFavorite(FavoriteType.evento, widget.eventId),
            );
          },
        ),
      ],
      body: FutureBuilder<Evento>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const RttShimmerDetail();
          }
          if (snap.hasError) {
            return RttErrorWidget(
              message: snap.error.toString(),
              onRetry: () => setState(() { future = repo.fetchEventoById(widget.eventId); }),
            );
          }
          if (snap.data == null) {
            return const Center(child: Text('Evento no encontrado.'));
          }
          return _EventoDetalleBody(evento: snap.data!);
        },
      ),
    );
  }
}

class _EventoDetalleBody extends StatelessWidget {
  const _EventoDetalleBody({required this.evento});
  final Evento evento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // --- Imagen ---
        if (evento.imageUrl.isNotEmpty)
          Hero(
            tag: 'evento-img-${evento.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: evento.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.black12,
                  child: const Icon(Icons.broken_image, size: 48, color: Colors.black26),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // --- Titulo ---
        Text(
          evento.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 16),

        // --- Metadatos ---
        _MetadataRow(
          icon: Icons.calendar_today,
          text: EventosShare.formatDate(evento),
        ),
        const SizedBox(height: 8),
        _MetadataRow(
          icon: Icons.location_on_outlined,
          text: evento.isPrivate ? 'Ubicacion privada' : evento.location,
        ),
        if (evento.priceText.isNotEmpty) ...[
          const SizedBox(height: 8),
          _MetadataRow(
            icon: Icons.confirmation_num_outlined,
            text: evento.priceText,
          ),
        ],

        // --- Badge evento privado ---
        if (evento.isPrivate) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'Evento privado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // --- Boton compartir ---
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => EventosShare.shareEvento(evento),
            icon: const Icon(Icons.share_outlined),
            label: const Text('COMPARTIR EVENTO'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RttColors.red,
              side: const BorderSide(color: RttColors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
