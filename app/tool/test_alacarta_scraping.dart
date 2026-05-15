// Test independiente del scraping de "A la carta" (sin importar Flutter).
//
//   dart run tool/test_alacarta_scraping.dart
//
// Reproduce la misma lógica que AlaCartaRepository contra la web real y
// comprueba que el formato de URL de audio (mdstrm.com/audio/{id}.m3u8) funciona.
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

const String base = 'https://radioteletaxi.com';

Future<void> main() async {
  print('1) Cargando listas de shows...');
  final podcasts = await _parseShowList('$base/a-la-carta/podcast/', 'podcast');
  final u7d = await _parseShowList('$base/a-la-carta/u7d/', 'radioshow');
  final shows = [...podcasts, ...u7d];
  print('   ${podcasts.length} podcasts + ${u7d.length} u7d = ${shows.length} shows totales');
  for (final s in shows) {
    print('   - [${s['type']}] ${s['title']} (${s['slug']})');
  }

  if (shows.isEmpty) {
    stderr.writeln('FALLO: no se encontraron shows.');
    exit(1);
  }

  // Probar el primer podcast
  final target = podcasts.isNotEmpty ? podcasts.first : shows.first;
  print('\n2) Cargando detalle de: ${target['title']}');
  final episodes = await _fetchEpisodes('$base/a-la-carta/${target['slug']}/', target['slug']!, target['title']!);
  print('   ${episodes.length} episodios encontrados');
  for (final ep in episodes.take(3)) {
    print('   * ${ep['title']}');
    print('     fecha:    ${ep['date']}');
    print('     mediaId:  ${ep['mediaId']}');
    print('     audioUrl: ${ep['audioUrl']}');
  }

  if (episodes.isEmpty) {
    stderr.writeln('FALLO: el show no tiene episodios.');
    exit(1);
  }

  // Comprobar que la URL del audio responde 200
  print('\n3) HEAD al audio del primer episodio...');
  final url = episodes.first['audioUrl']!;
  final res = await http.head(Uri.parse(url));
  print('   $url → ${res.statusCode}');
  if (res.statusCode != 200) {
    stderr.writeln('FALLO: el audio no devolvió 200');
    exit(2);
  }

  print('\n✅ OK · Scraping de A la Carta funciona contra la web real.');
}

Future<List<Map<String, String>>> _parseShowList(String url, String type) async {
  final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0'});
  final doc = html_parser.parse(res.body);
  final result = <Map<String, String>>[];
  final seen = <String>{};
  final blacklist = {'podcast', 'u7d', ''};

  final anchors = doc.querySelectorAll('a[href*="/a-la-carta/"]');
  for (final a in anchors) {
    final href = a.attributes['href'] ?? '';
    final m = RegExp(r'/a-la-carta/([a-z0-9-]+)/?$').firstMatch(href);
    if (m == null) continue;
    final slug = m.group(1)!;
    if (blacklist.contains(slug)) continue;
    if (seen.contains(slug)) continue;

    final img = a.querySelector('img');
    final title = (img?.attributes['alt'] ?? slug).trim();
    final image = _pickImg(img);
    if (title.isEmpty || image.isEmpty) continue;

    seen.add(slug);
    result.add({
      'slug': slug,
      'title': _decode(title),
      'imageUrl': image,
      'type': type,
    });
  }
  return result;
}

Future<List<Map<String, String>>> _fetchEpisodes(String url, String showSlug, String showTitle) async {
  final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0'});
  final doc = html_parser.parse(res.body);
  final cards = doc.querySelectorAll('.rp-programa-card');
  final result = <Map<String, String>>[];
  for (final card in cards) {
    final btn = card.querySelector('button.rp-play-episode');
    if (btn == null) continue;
    final mediaId = (btn.attributes['data-media-id'] ?? '').trim();
    final guid = (btn.attributes['data-episode-guid'] ?? '').trim();
    if (mediaId.isEmpty) continue;

    result.add({
      'mediaId': mediaId,
      'guid': guid,
      'title': _decode((card.querySelector('.rp-episode-title')?.text ?? '').trim()),
      'date': (card.querySelector('.rp-meta')?.text ?? '').trim(),
      'audioUrl': 'https://mdstrm.com/audio/$mediaId.m3u8',
      'imageUrl': _pickImg(card.querySelector('.rp-programa-card-image img')),
      'showSlug': showSlug,
      'showTitle': showTitle,
    });
  }
  return result;
}

String _pickImg(Element? img) {
  if (img == null) return '';
  final dataSrc = (img.attributes['data-src'] ?? '').trim();
  if (dataSrc.isNotEmpty && !dataSrc.startsWith('data:')) return dataSrc;
  final src = (img.attributes['src'] ?? '').trim();
  if (src.isNotEmpty && !src.startsWith('data:')) return src;
  return '';
}

String _decode(String s) {
  return s
      .replaceAll('&amp;', '&')
      .replaceAll('&#039;', "'")
      .replaceAll('&#8217;', '’')
      .replaceAll('&#8211;', '–')
      .replaceAll('&quot;', '"')
      .replaceAll('&nbsp;', ' ');
}
