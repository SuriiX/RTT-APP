import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../widgets/rtt_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  // Pon aquí la URL real de tu política en WP
  static const policyUrl = 'https://radioteletaxi.com/politica-de-privacidad-app/';

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Política de Privacidad',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: () {},
        ),
      ],
      body: FutureBuilder<String>(
        future: _fetchHtml(),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error cargando política: ${snap.error}'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final html = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              HtmlWidget(
                html,
                textStyle: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _fetchHtml() async {
    // Sin meter un cliente gigante: usamos NetworkAssetBundle simple
    final uri = Uri.parse(policyUrl);
    final data = await NetworkAssetBundle(uri).load('');
    return String.fromCharCodes(data.buffer.asUint8List());
  }
}
