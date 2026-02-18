import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../../widgets/rtt_scaffold.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  // URL real de tu política en WordPress
  static const String policyUrl =
      'https://radioteletaxi.com/politica-de-privacidad-app/';

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late Future<String> _futureHtml;

  @override
  void initState() {
    super.initState();
    _futureHtml = _fetchHtml();
  }

  Future<String> _fetchHtml() async {
    final response = await http.get(Uri.parse(PrivacyPolicyPage.policyUrl));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Error ${response.statusCode} cargando la política de privacidad');
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
      PrivacyPolicyPage.policyUrl,
      subject: 'Política de Privacidad - Radio Tele Taxi',
    );
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Política de Privacidad',
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
            return const Center(child: CircularProgressIndicator());
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
                    'No se pudo cargar la política.',
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

          final html = snap.data!;

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
