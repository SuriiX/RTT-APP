import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/rtt_scaffold.dart';
import '../eventos/evento_model.dart';
import '../eventos/eventos_repository.dart';

class EntradasPage extends StatefulWidget {
  const EntradasPage({super.key});

  @override
  State<EntradasPage> createState() => _EntradasPageState();
}

class _EntradasPageState extends State<EntradasPage> {
  final repo = EventosRepository();
  late Future<List<Evento>> future;

  @override
  void initState() {
    super.initState();
    future = _fetchEntradas();
  }

  Future<List<Evento>> _fetchEntradas() async {
    final all = await repo.fetchEventos();
    return all
        .where((e) => e.tieneEntradas || e.linkCompra.isNotEmpty)
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      future = _fetchEntradas();
    });
    await future;
  }

  Future<void> _openCompra(String url) async {
    if (url.trim().isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Entradas',
      body: FutureBuilder<List<Evento>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final entradas = snap.data ?? [];
          if (entradas.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No hay entradas disponibles ahora mismo.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: entradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _entradaCard(entradas[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _entradaCard(Evento e) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.featuredImage.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: e.featuredImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(height: 180, color: Colors.black12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (e.agotadas)
                      _chip('Agotadas', const Color(0xFFB71C1C))
                    else if (e.proximamenteALaVenta)
                      _chip('Proximamente', const Color(0xFF6D4C41))
                    else
                      _chip('Entradas', const Color(0xFF2E7D32)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${e.fechaInicio} · ${e.lugar}',
                  style: const TextStyle(color: Colors.black54),
                ),
                if (e.precioDisplay.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(e.precioDisplay,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        (e.agotadas || e.linkCompra.trim().isEmpty)
                            ? null
                            : () => _openCompra(e.linkCompra),
                    icon: const Icon(Icons.confirmation_num_outlined),
                    label: Text(
                      e.agotadas
                          ? 'ENTRADAS AGOTADAS'
                          : (e.proximamenteALaVenta
                              ? 'PROXIMAMENTE'
                              : 'COMPRAR ENTRADAS'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}
