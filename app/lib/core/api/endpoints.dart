class Endpoints {
  static const String baseUrl = 'https://radioteletaxi.com/rtt-app/v1';

  static String home() => '$baseUrl/home';
  static String settings() => '$baseUrl/settings';
  static String directo() => '$baseUrl/directo';
  static String cover() => '$baseUrl/cover.jpg';

  static String programacion() => '$baseUrl/programacion';
  static String actualidad({int page = 1, int perPage = 10}) =>
      '$baseUrl/actualidadv2?page=$page&per_page=$perPage';
  static String eventos() => '$baseUrl/eventos';
  static String frecuencias() => '$baseUrl/frecuencias';
}
