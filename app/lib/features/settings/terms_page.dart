import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late Future<String> _futureHtml;

  @override
  void initState() {
    super.initState();
    _futureHtml = _fetchHtml();
  }

  Future<String> _fetchHtml() async {
    try {
      final response = await ApiClient.instance.getRaw(Endpoints.termsOfService());
      return response.body;
    } catch (e) {
      debugPrint('Terms of service fetch error: $e');
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureHtml = _fetchHtml();
    });
    await _futureHtml;
  }

  void _share() {
    Share.share(
      Endpoints.termsOfService(),
      subject: 'Términos de Servicio - Radio Tele Taxi',
    );
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Términos de Servicio',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: _share,
        ),
      ],
      body: FutureBuilder<String>(
        future: _futureHtml,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const RttShimmerDetail();
          }

          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudieron cargar los términos.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snap.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final html = snap.data ?? '';
          if (html.isEmpty) {
            return const Center(child: Text('Sin contenido disponible'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: [
                HtmlWidget(
                  html,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  renderMode: RenderMode.column,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
