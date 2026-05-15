/// Endpoints del backend de Radio TeleTaxi.
///
/// El backend expone los datos a través de dos plugins WordPress:
///   • `rtt-app-api`        → API de contenido (`/app-rest/v1/*`)
///   • `rtt-mediastream`    → BBDD espejo de Mediastream (sólo lectura cuando
///                            el plugin exponga endpoints públicos; los nombres
///                            previstos se documentan abajo).
class Endpoints {
  Endpoints._();

  /// Base de la API de contenido (plugin `rtt-app-api`).
  static const String baseApp = 'https://radioteletaxi.com/app-rest/v1';

  /// Base prevista para el plugin `rtt-mediastream` cuando exponga
  /// endpoints públicos de shows/episodios para la sección "A la carta".
  /// Hasta entonces los servicios que la usen devolverán listas vacías
  /// y la UI muestra estado vacío.
  static const String baseMediastream = 'https://radioteletaxi.com/wp-json/rtt-mediastream/v1';

  // ── Contenido principal ──
  static String directo() => '$baseApp/directo';
  static String programacion() => '$baseApp/programacion';
  static String frecuencias() => '$baseApp/frecuencias';
  static String actualidadList({int page = 1, int perPage = 10}) =>
      '$baseApp/actualidadv2?page=$page&per_page=$perPage';
  static String eventosList() => '$baseApp/eventos';

  // ── Streaming en directo ──
  /// Devuelve 302 al URL real del icecast en Mediastream.
  /// http.Client sigue redirects por defecto, así que basta con apuntar aquí.
  static String streamAndroid() => '$baseApp/streaming-android';
  static String streamIos() => '$baseApp/streaming-ios';

  // ── Cover del directo ──
  static String cover() => '$baseApp/cover.jpg';

  // ── A la carta (Mediastream mirror) ──
  // Los nombres están previstos según la convención del plugin. Cuando el
  // cliente publique los endpoints, sólo hay que ajustar las rutas si difieren.
  static String alaCartaShows() => '$baseMediastream/shows';
  static String alaCartaShowById(String id) => '$baseMediastream/shows/$id';
  static String alaCartaShowEpisodes(String id) =>
      '$baseMediastream/shows/$id/episodes';
  static String alaCartaU7d() => '$baseMediastream/u7d';

  // ── Páginas web (legal) ──
  // La política oficial está en /politica-de-privacidad/ del WordPress.
  // Si la página cae, la app cae a un fallback offline empaquetado.
  static String privacyPolicy() =>
      'https://radioteletaxi.com/politica-de-privacidad/';
  static String termsOfService() =>
      'https://radioteletaxi.com/terminos-de-uso-app/';
}
