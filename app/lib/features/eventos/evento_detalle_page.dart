import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final repo = EventosRepository();
  late Future<Evento?> future;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse(widget.eventId) ?? 0;
    future = repo.fetchEventoById(id);
  }

  Future<void> _openCompra(String url) async {
    if (url.trim().isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Evento',
      body: FutureBuilder<Evento?>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error:\n${snap.error}'));
          }
          final e = snap.data;
          if (e == null) {
            return const Center(child: Text('No se encontró el evento'));
          }
          return _body(context, e);
        },
      ),
    );
  }

  Widget _body(BuildContext context, Evento e) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
      children: [
        // Imagen destacada
        if (e.featuredImage.isNotEmpty)
          CachedNetworkImage(
            imageUrl: e.featuredImage,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                Container(height: 240, color: Colors.black12),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titulo
              Text(
                e.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 16),

              // Info cards
              _infoSection(e),

              const SizedBox(height: 20),

              // Boton comprar entradas
              if (e.tieneEntradas || e.linkCompra.isNotEmpty) _buyButton(e),

              // Contenido HTML
              if (e.content.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                Html(data: e.content),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoSection(Evento e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fecha
          if (e.fechaInicio.isNotEmpty)
            _infoRow(
              Icons.calendar_today,
              _buildFechaText(e),
            ),

          // Hora
          if (e.hora.isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.access_time, e.hora),
          ],

          // Lugar
          if (e.lugar.isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.location_on, e.lugar),
          ],

          // Direccion
          if (e.direccion.isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.map_outlined, e.direccion),
          ],

          // Precio
          if (e.precioDisplay.isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.local_activity, e.precioDisplay),
          ],
        ],
      ),
    );
  }

  String _buildFechaText(Evento e) {
    if (e.fechaFin.isNotEmpty && e.fechaFin != e.fechaInicio) {
      return '${e.fechaInicio} - ${e.fechaFin}';
    }
    return e.fechaInicio;
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE53935)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buyButton(Evento e) {
    final agotadas = e.agotadas;
    final prox = e.proximamenteALaVenta;
    final link = e.linkCompra.trim();

    String label;
    if (agotadas) {
      label = 'ENTRADAS AGOTADAS';
    } else if (prox) {
      label = 'PROXIMAMENTE A LA VENTA';
    } else {
      label = 'COMPRAR ENTRADAS';
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor:
              agotadas ? Colors.grey : const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: (agotadas || prox || link.isEmpty)
            ? null
            : () => _openCompra(link),
        icon: const Icon(Icons.confirmation_num_outlined),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
