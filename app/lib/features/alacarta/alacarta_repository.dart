import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../core/api/api_client.dart';
import 'models.dart';

/// Repositorio de "A la carta" que consume las páginas públicas del
/// plugin WordPress en `radioteletaxi.com/a-la-carta/...`.
///
/// La web ya renderiza todo lo necesario (lista de shows + episodios con
/// sus `data-media-id` y `data-episode-guid`), así que el repo scrapea el
/// HTML y mapea a los modelos de la app. El audio se reproduce contra
/// `https://mdstrm.com/audio/{media-id}.m3u8` (HLS, soportado por just_audio).
///
/// Cuando el plugin `rtt-mediastream` exponga endpoints REST nativos
/// bastará con cambiar `_fetchHtml(...)` por `getMap/getList` del ApiClient.
class AlaCartaRepository {
  AlaCartaRepository._();
  static final AlaCartaRepository instance = AlaCartaRepository._();

  final ApiClient _api = ApiClient.instance;

  static const String _base = 'https://radioteletaxi.com';
  static const String _listPodcast = '$_base/a-la-carta/podcast/';
  static const String _listU7d = '$_base/a-la-carta/u7d/';

  /// Cache simple en memoria (válida durante la sesión).
  List<AlaCartaShow>? _allShowsCache;
  final Map<String, AlaCartaShow> _detailCache = {};

  bool _backendOnline = true;
  bool get isBackendOnline => _backendOnline;

  // ──────────────────────────────────────────────────────────────────────
  // SHOWS
  // ──────────────────────────────────────────────────────────────────────

  /// Devuelve todos los shows (podcasts + radioshows).
  Future<List<AlaCartaShow>> fetchShows() async {
    if (_allShowsCache != null) return _allShowsCache!;
    return _refreshAllShows();
  }

  Future<List<AlaCartaShow>> _refreshAllShows() async {
    try {
      // Cargamos las dos categorías en paralelo y luego unimos.
      final results = await Future.wait([
        _parseShowList(_listPodcast, 'podcast'),
        _parseShowList(_listU7d, 'radioshow'),
      ]);
      final shows = <AlaCartaShow>[];
      shows.addAll(results[0]);
      shows.addAll(results[1]);

      _allShowsCache = shows;
      _backendOnline = true;
      return shows;
    } catch (e) {
      _backendOnline = false;
      debugPrint('AlaCartaRepository.fetchShows error: $e');
      return const [];
    }
  }

  Future<List<AlaCartaShow>> fetchPodcasts() async {
    final all = await fetchShows();
    return all.where((s) => s.isPodcast).toList();
  }

  Future<List<AlaCartaShow>> fetchU7D() async {
    final all = await fetchShows();
    return all.where((s) => s.isRadioshow).toList();
  }

  /// Devuelve el show con [slug] y sus episodios (carga la página detalle).
  Future<AlaCartaShow?> fetchShowById(String slug) async {
    if (_detailCache.containsKey(slug)) return _detailCache[slug];

    try {
      final url = '$_base/a-la-carta/$slug/';
      final html = await _fetchHtml(url);
      final doc = html_parser.parse(html);

      // 1) Datos base: si no estaba en cache, intentamos sacar título e imagen
      //    del propio detalle (el <title> y el primer <img> del listado).
      var base = (_allShowsCache ?? const <AlaCartaShow>[])
          .where((s) => s.slug == slug)
          .firstOrNull;

      base ??= _buildShowFromDetail(doc, slug);
      if (base == null) return null;

      // 2) Descripción del show, si la página la expone.
      final description = _extractShowDescription(doc);

      // 3) Episodios.
      final episodes = _extractEpisodes(doc, base.slug, base.title);

      final populated = base.copyWith(
        description: description.isNotEmpty ? description : base.description,
        episodes: episodes,
      );

      _detailCache[slug] = populated;
      _backendOnline = true;
      return populated;
    } catch (e) {
      debugPrint('AlaCartaRepository.fetchShowById($slug) error: $e');
      return null;
    }
  }

  /// Atajo: episodios de un show.
  Future<List<AlaCartaEpisode>> fetchEpisodesOfShow(String slug) async {
    final show = await fetchShowById(slug);
    return show?.episodes ?? const [];
  }

  // ──────────────────────────────────────────────────────────────────────
  // PARSING HTML
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AlaCartaShow>> _parseShowList(String url, String type) async {
    final html = await _fetchHtml(url);
    final doc = html_parser.parse(html);

    // Cada show aparece como un <a href="/a-la-carta/{slug}/"> que envuelve
    // una card con <img alt="{título}" data-src="{imagen}">.
    final shows = <AlaCartaShow>[];
    final seen = <String>{};

    // Sólo nos quedamos con los links que apunten a un slug específico,
    // descartando los meta-links a /podcast/ o /u7d/ que aparecen como nav.
    final blacklist = {'podcast', 'u7d', ''};

    final anchors = doc.querySelectorAll('a[href*="/a-la-carta/"]');
    for (final a in anchors) {
      final href = a.attributes['href'] ?? '';
      final m = RegExp(r'/a-la-carta/([a-z0-9-]+)/?$').firstMatch(href);
      if (m == null) continue;
      final slug = m.group(1)!;
      if (blacklist.contains(slug)) continue;
      if (seen.contains(slug)) continue;

      // El primer <img> hijo nos da título y URL.
      final img = a.querySelector('img');
      final title = (img?.attributes['alt'] ?? slug).trim();
      final image = _pickImg(img);

      // Algunos enlaces son del propio botón "Ver más" sin imagen — los descartamos.
      if (title.isEmpty || image.isEmpty) continue;

      seen.add(slug);
      shows.add(AlaCartaShow(
        slug: slug,
        title: _decodeEntities(title),
        imageUrl: image,
        type: type,
      ));
    }

    return shows;
  }

  AlaCartaShow? _buildShowFromDetail(Document doc, String slug) {
    final h1 = doc.querySelector('h1');
    final title = (h1?.text ?? slug).trim();

    // Usa la primera imagen razonable de la página de detalle.
    final img = doc.querySelector('.rp-programa-detalle img, .rp-show-cover img, .elementor-widget-image img');
    final image = _pickImg(img);

    if (title.isEmpty) return null;
    return AlaCartaShow(
      slug: slug,
      title: _decodeEntities(title),
      imageUrl: image,
      type: 'podcast', // se sobrescribirá si el show está en cache
    );
  }

  String _extractShowDescription(Document doc) {
    final el = doc.querySelector('.rp-show-desc, .rp-programa-desc, .rp-programa-detalle-desc');
    return (el?.text ?? '').trim();
  }

  List<AlaCartaEpisode> _extractEpisodes(
    Document doc,
    String showSlug,
    String showTitle,
  ) {
    final cards = doc.querySelectorAll('.rp-programa-card');
    final episodes = <AlaCartaEpisode>[];

    for (final card in cards) {
      final btn = card.querySelector('button.rp-play-episode');
      if (btn == null) continue;
      final mediaId = (btn.attributes['data-media-id'] ?? '').trim();
      final guid = (btn.attributes['data-episode-guid'] ?? '').trim();
      if (mediaId.isEmpty) continue;

      final titleEl = card.querySelector('.rp-episode-title');
      final title = _decodeEntities((titleEl?.text ?? '').trim());

      final dateEl = card.querySelector('.rp-meta');
      final date = (dateEl?.text ?? '').trim();

      final descEl = card.querySelector('.rp-episode-desc');
      final desc = _decodeEntities((descEl?.text ?? '').trim());

      final img = card.querySelector('.rp-programa-card-image img');
      final image = _pickImg(img);

      episodes.add(AlaCartaEpisode(
        mediaId: mediaId,
        guid: guid,
        showSlug: showSlug,
        showTitle: showTitle,
        title: title,
        description: desc,
        imageUrl: image,
        dateText: date,
      ));
    }
    return episodes;
  }

  /// Decide qué URL usar de un `<img>` con lazy-load (data-src) o normal (src).
  String _pickImg(Element? img) {
    if (img == null) return '';
    final dataSrc = (img.attributes['data-src'] ?? '').trim();
    if (dataSrc.isNotEmpty && !dataSrc.startsWith('data:')) return dataSrc;
    final src = (img.attributes['src'] ?? '').trim();
    if (src.isNotEmpty && !src.startsWith('data:')) return src;
    return '';
  }

  /// Decodifica entidades HTML básicas (&#039; &amp; &nbsp;…).
  String _decodeEntities(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8211;', '–')
        .replaceAll('&quot;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  Future<String> _fetchHtml(String url) async {
    final res = await _api.getRaw(url);
    return res.body;
  }
}

extension _IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
