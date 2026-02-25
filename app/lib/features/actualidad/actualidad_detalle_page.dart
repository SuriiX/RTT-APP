import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../widgets/rtt_scaffold.dart';
import 'actualidad_repository.dart';
import 'noticia_model.dart';

class ActualidadDetallePage extends StatefulWidget {
  const ActualidadDetallePage({super.key, required this.postId});
  final String postId;

  @override
  State<ActualidadDetallePage> createState() => _ActualidadDetallePageState();
}

class _ActualidadDetallePageState extends State<ActualidadDetallePage> {
  late final ActualidadRepository repo;
  late Future<Noticia?> future;

  @override
  void initState() {
    super.initState();
    repo = ActualidadRepository();
    future = _loadById(widget.postId);
  }

  Future<Noticia?> _loadById(String id) async {
    final res = await repo.fetchActualidad(page: 1, perPage: 50);
    final targetId = int.tryParse(id) ?? -1;
    for (final n in res.news) {
      if (n.id == targetId) return n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Actualidad',
      body: FutureBuilder<Noticia?>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error:\n${snap.error}'));
          }
          final n = snap.data;
          if (n == null) {
            return const Center(child: Text('No se encontró la noticia'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              if (n.featuredImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(n.featuredImage, fit: BoxFit.cover),
                ),
              const SizedBox(height: 14),
              Text(
                n.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                n.date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // HTML WordPress
              Html(data: n.content),
            ],
          );
        },
      ),
    );
  }
}
