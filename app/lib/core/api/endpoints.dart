class Endpoints {
  Endpoints._();

  /// Base URL para la API principal de la app (home, settings, directo, etc.)
  static const String baseUrl = 'https://radioteletaxi.com/rtt-app/v1';

  /// Base URL para la API REST de contenido (actualidad, eventos)
  static const String baseUrlRest = 'https://radioteletaxi.com/app-rest/v1';

  // ── API principal ──
  static String home() => '$baseUrl/home';
  static String settings() => '$baseUrl/settings';
  static String directo() => '$baseUrl/directo';
  static String cover() => '$baseUrl/cover.jpg';
  static String programacion() => '$baseUrl/programacion';
  static String frecuencias() => '$baseUrl/frecuencias';

  // ── API REST (contenido WordPress) ──
  static String actualidadList({int page = 1, int perPage = 10}) =>
      '$baseUrlRest/actualidadv2?page=$page&per_page=$perPage';
  static String eventosList() => '$baseUrlRest/eventos';
  static String eventoById(String id) => '$baseUrlRest/eventos/$id';

  // ── Páginas web ──
  static String privacyPolicy() =>
      'https://radioteletaxi.com/politica-de-privacidad-app/';
  static String termsOfService() =>
      'https://radioteletaxi.com/terminos-de-uso-app/';
}
