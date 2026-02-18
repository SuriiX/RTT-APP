import 'package:flutter/material.dart';
import '../../widgets/rtt_scaffold.dart';
import 'evento_model.dart';
import 'eventos_repository.dart';

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
    repo = EventosRepository(baseUrl: 'https://radioteletaxi.com/app-rest/v1'); // TODO
    future = repo.fetchEventoById(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Evento',
      body: FutureBuilder<Evento>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error:\n${snap.error}'));
          }
          final e = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              if (e.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(e.imageUrl, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(e.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text('${e.location} • ${e.priceText}'),
              const SizedBox(height: 24),
              const Text('Detalle pendiente de completar (descripción, link de compra, etc.)'),
            ],
          );
        },
      ),
    );
  }
}
