import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/rtt_scaffold.dart';
import 'evento_model.dart';
import 'eventos_repository.dart';
import 'eventos_share.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final repo = EventosRepository();
  late Future<List<Evento>> future;

  @override
  void initState() {
    super.initState();
    future = repo.fetchEventos();
  }

  Future<void> _refresh() async {
    setState(() {
      future = repo.fetchEventos();
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Eventos',
      body: FutureBuilder<List<Evento>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error cargando eventos:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final eventos = snap.data ?? [];
          if (eventos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No hay eventos disponibles')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: eventos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final e = eventos[i];
                return _EventoCard(
                  evento: e,
                  onTap: () => context.push('/eventos/${e.id}'),
                  onShare: () => EventosShare.shareEvento(e),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  const _EventoCard({
    required this.evento,
    required this.onTap,
    required this.onShare,
  });

  final Evento evento;
  final VoidCallback onTap;
  final VoidCallback onShare;

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
            if (evento.featuredImage.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: evento.featuredImage,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox(height: 140),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          evento.fechaInicio,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.ios_share, size: 20),
                        onPressed: onShare,
                        tooltip: 'Compartir',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    evento.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 12),

                  _RowIconText(
                    icon: Icons.location_on,
                    text: evento.lugar.isNotEmpty ? evento.lugar : 'Por confirmar',
                  ),
                  const SizedBox(height: 8),

                  if (evento.precioDisplay.isNotEmpty)
                    _RowIconText(
                      icon: Icons.local_activity,
                      text: evento.precioDisplay,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowIconText extends StatelessWidget {
  const _RowIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.red),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ),
      ],
    );
  }
}
