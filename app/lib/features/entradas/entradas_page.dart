import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_animated_list_item.dart';
import '../../widgets/rtt_error_widget.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';

class EntradasPage extends StatelessWidget {
  const EntradasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RttScaffold(
      title: 'Entradas',
      body: _EntradasBody(),
    );
  }
}

class _EntradasBody extends StatefulWidget {
  const _EntradasBody();

  @override
  State<_EntradasBody> createState() => _EntradasBodyState();
}

class _EntradasBodyState extends State<_EntradasBody> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiClient.instance.getList(Endpoints.eventosList());
  }

  Future<void> _refresh() async {
    setState(() {
      future = ApiClient.instance.getList(Endpoints.eventosList());
    });
    await future;
  }

  Future<void> _openCompra(String url) async {
    if (url.trim().isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const RttShimmerList();
        }
        if (snap.hasError) {
          return RttErrorWidget(
            message: snap.error.toString(),
            onRetry: _refresh,
          );
        }

        final raw = snap.data ?? [];

        // FILTRO: solo eventos con entradas
        final entradas = raw.where((e) {
          final m = (e is Map) ? e : <String, dynamic>{};
          final tiene = (m['tiene_entradas'] == true);
          final link = (m['link_compra_de_entrada'] ?? '').toString().trim();
          return tiene || link.isNotEmpty;
        }).toList();

        if (entradas.isEmpty) {
          return const Center(child: Text('No hay entradas disponibles ahora mismo.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entradas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = entradas[i] as Map;

              final img = (e['featured_image'] ?? '').toString();
              final title = (e['title'] ?? '').toString();
              final fecha = (e['fecha_inicio'] ?? '').toString();
              final lugar = (e['lugar'] ?? '').toString();
              final precio = (e['precio'] ?? '').toString();

              final agotadas = (e['agotadas'] == true);
              final prox = (e['proximamente_a_la_venta'] == true);
              final link = (e['link_compra_de_entrada'] ?? '').toString();

              return RttAnimatedListItem(
                index: i,
                child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (img.trim().isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: img,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(height: 180, color: Colors.black12),
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
                                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              if (agotadas)
                                _chip('Agotadas', RttColors.darkRed)
                              else if (prox)
                                _chip('Próximamente', const Color(0xFF6D4C41))
                              else
                                _chip('Entradas', const Color(0xFF2E7D32)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (fecha.trim().isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(fecha, style: const TextStyle(color: Colors.black54)),
                                ),
                              ],
                            ),
                          if (lugar.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(lugar, style: const TextStyle(color: Colors.black54)),
                                ),
                              ],
                            ),
                          ],
                          if (precio.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(precio, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: (agotadas || link.trim().isEmpty) ? null : () => _openCompra(link),
                              icon: const Icon(Icons.confirmation_num_outlined),
                              label: Text(
                                agotadas
                                    ? 'ENTRADAS AGOTADAS'
                                    : (prox ? 'PRÓXIMAMENTE' : 'COMPRAR ENTRADAS'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
