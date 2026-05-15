/// Modelos de la sección "A la carta".
///
/// Los datos se obtienen scrapeando las páginas públicas
/// `radioteletaxi.com/a-la-carta/...`, que ya están en producción y
/// son renderizadas por el plugin de WordPress de Radio TeleTaxi.
/// El audio se sirve directamente desde Mediastream:
///
///     https://mdstrm.com/audio/{media-id}.m3u8     (HLS, recomendado)
///     https://mdstrm.com/audio/{media-id}.m4a      (descargable directo)
class AlaCartaShow {
  final String slug;
  final String title;
  final String imageUrl;

  /// Categoría declarada por la página del plugin: `podcast` o `radioshow`.
  /// Se determina según en qué índice apareció el show: `/podcast/` o `/u7d/`.
  final String type;

  /// Descripción del programa (solo disponible en la página de detalle).
  final String description;

  /// Episodios (sólo cuando se obtiene desde la página de detalle).
  final List<AlaCartaEpisode> episodes;

  bool get isPodcast => type.toLowerCase() == 'podcast';
  bool get isRadioshow => type.toLowerCase() == 'radioshow';

  String get url => 'https://radioteletaxi.com/a-la-carta/$slug/';

  /// Id estable para usar como path parameter en go_router.
  String get id => slug;

  const AlaCartaShow({
    required this.slug,
    required this.title,
    required this.imageUrl,
    required this.type,
    this.description = '',
    this.episodes = const [],
  });

  AlaCartaShow copyWith({
    String? description,
    List<AlaCartaEpisode>? episodes,
  }) {
    return AlaCartaShow(
      slug: slug,
      title: title,
      imageUrl: imageUrl,
      type: type,
      description: description ?? this.description,
      episodes: episodes ?? this.episodes,
    );
  }
}

class AlaCartaEpisode {
  /// Identificador del media en Mediastream (lo que va en la URL de audio).
  final String mediaId;

  /// Identificador del episodio (a veces distinto del media).
  final String guid;

  final String showSlug;
  final String showTitle;
  final String title;
  final String description;
  final String imageUrl;
  final String dateText;

  /// `https://mdstrm.com/audio/{mediaId}.m3u8`
  String get audioUrl => 'https://mdstrm.com/audio/$mediaId.m3u8';

  /// Página pública del episodio (compartible).
  String get shareUrl =>
      'https://radioteletaxi.com/a-la-carta/$showSlug/?episode=$guid';

  /// Id estable.
  String get id => guid.isNotEmpty ? guid : mediaId;

  /// Compatibilidad con la pantalla previa.
  String get formattedDate => dateText;

  /// La web no expone duración; lo dejamos vacío para que la UI lo oculte.
  String get formattedDuration => '';

  const AlaCartaEpisode({
    required this.mediaId,
    required this.guid,
    required this.showSlug,
    required this.showTitle,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.dateText,
  });
}
