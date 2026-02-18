import 'package:flutter/material.dart';
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
  late final EventosRepository repo;
  late Future<List<Evento>> future;

  @override
  void initState() {
    super.initState();

    repo = EventosRepository(baseUrl: 'https://radioteletaxi.com/app-rest/v1');

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

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final location = evento.isPrivate ? 'Privat' : evento.location;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (evento.imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  evento.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 140),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha + Share (como el icono del header en tu screenshot)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDate(evento.date),
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
                    text: location,
                  ),
                  const SizedBox(height: 8),

                  if (evento.priceText.isNotEmpty)
                    _RowIconText(
                      icon: Icons.local_activity,
                      text: evento.priceText,
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
