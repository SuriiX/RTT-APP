class Endpoints {
  static const String baseUrl = 'https://radioteletaxi.com/app-rest/v1';

  /// URL de streaming (redirige al .mp3 real)
  static const String streamingUrl =
      'https://radiott-web.streaming-pro.com:6103/radiott.mp3';

  static String directo() => '$baseUrl/directo';
  static String cover() => '$baseUrl/cover.jpg';

  static String programacion() => '$baseUrl/programacion';
  static String actualidad({int page = 1, int perPage = 10}) =>
      '$baseUrl/actualidadv2?page=$page&per_page=$perPage';
  static String eventos() => '$baseUrl/eventos';
  static String frecuencias() => '$baseUrl/frecuencias';
}
