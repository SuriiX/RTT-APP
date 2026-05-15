import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/api_client.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';

/// Pantalla genérica para mostrar documentos legales (privacidad / términos).
///
/// Modos de carga:
///  - Si [remoteUrl] es `null`: la pantalla es 100 % estática. Sólo lee
///    [fallbackAsset] del bundle y nunca toca la red. Útil para documentos
///    que deben mostrarse igual aunque el WordPress esté caído (p. ej.
///    Política de Privacidad — exigido por las stores).
///  - Si [remoteUrl] no es `null`: intenta descargar el HTML público;
///    ante cualquier error de red o status 4xx/5xx cae al asset local.
class LegalPage extends StatefulWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.fallbackAsset,
    this.remoteUrl,
    this.shareSubject,
  });

  final String title;
  final String fallbackAsset;
  final String? remoteUrl;
  final String? shareSubject;

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  late Future<_LegalContent> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_LegalContent> _load() async {
    final url = widget.remoteUrl;
    if (url == null) {
      // Modo estático puro: nunca tocamos la red.
      final html = await rootBundle.loadString(widget.fallbackAsset);
      return _LegalContent(html: html, fromFallback: false);
    }
    try {
      final response = await ApiClient.instance.getRaw(url);
      final body = response.body.trim();
      if (body.isEmpty) throw const ApiException('Respuesta vacía');
      return _LegalContent(html: body, fromFallback: false);
    } catch (_) {
      final html = await rootBundle.loadString(widget.fallbackAsset);
      return _LegalContent(html: html, fromFallback: true);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  void _share() {
    final url = widget.remoteUrl;
    if (url == null) return;
    Share.share(url, subject: widget.shareSubject ?? widget.title);
  }

  @override
  Widget build(BuildContext context) {
    final canShare = widget.remoteUrl != null;
    return RttScaffold(
      title: widget.title,
      actions: [
        if (canShare)
          IconButton(
            tooltip: 'Compartir',
            icon: const Icon(Icons.ios_share),
            onPressed: _share,
          ),
      ],
      body: FutureBuilder<_LegalContent>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const RttShimmerDetail();
          }
          final content = snap.data;
          if (content == null) {
            return const Center(child: Text('Sin contenido disponible'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: [
                if (content.fromFallback) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mostrando versión empaquetada (sin conexión o página no disponible).',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                HtmlWidget(
                  content.html,
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

class _LegalContent {
  const _LegalContent({required this.html, required this.fromFallback});
  final String html;
  final bool fromFallback;
}
