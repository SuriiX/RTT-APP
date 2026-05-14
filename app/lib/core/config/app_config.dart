/// Configuracion centralizada de la app cargada desde /settings.
///
/// Se inicializa una unica vez desde HomePage al arrancar la app.
/// Antes de eso, devuelve valores por defecto razonables.
class AppConfig {
  AppConfig._({
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.facebookUrl,
    required this.twitterUrl,
    required this.instagramUrl,
    required this.youtubeUrl,
    required this.whatsappUrl,
    required this.streamingUrl,
  });

  /// Instancia singleton. Null hasta que se llame [init].
  static AppConfig? _instance;

  /// Devuelve la instancia cargada o defaults si aun no se cargo.
  static AppConfig get instance => _instance ?? _defaults();

  /// Indica si ya se cargo desde la API.
  static bool get isLoaded => _instance != null;

  final String phoneNumber;
  final String whatsappNumber;
  final String facebookUrl;
  final String twitterUrl;
  final String instagramUrl;
  final String youtubeUrl;
  final String whatsappUrl;
  final String streamingUrl;

  /// Valores por defecto hardcodeados (fallback si la API no responde).
  static AppConfig _defaults() => AppConfig._(
        phoneNumber: '934661819',
        whatsappNumber: '34646212121',
        facebookUrl: 'https://www.facebook.com/RadioTeleTaxi',
        twitterUrl: 'https://twitter.com/RadioTeleTaxi',
        instagramUrl: 'https://www.instagram.com/radioteletaxi',
        youtubeUrl: 'https://www.youtube.com/@RadioTeleTaxi',
        whatsappUrl: 'https://wa.me/34646212121',
        streamingUrl: '',
      );

  /// Inicializa desde el JSON de /settings.
  static void init(Map<String, dynamic> settings) {
    final social = settings['social'];
    final socialMap =
        (social is Map<String, dynamic>) ? social : <String, dynamic>{};

    final streaming = settings['streaming'];
    final streamingMap =
        (streaming is Map<String, dynamic>) ? streaming : <String, dynamic>{};

    final phone = _str(settings['telefono']) ??
        _str(settings['phone']) ??
        '934661819';

    final whatsapp = _str(socialMap['whatsapp_number']) ??
        _str(settings['whatsapp']) ??
        '34646212121';

    _instance = AppConfig._(
      phoneNumber: phone,
      whatsappNumber: whatsapp,
      facebookUrl: _str(socialMap['facebook']) ?? 'https://www.facebook.com/RadioTeleTaxi',
      twitterUrl: _str(socialMap['twitter']) ?? 'https://twitter.com/RadioTeleTaxi',
      instagramUrl: _str(socialMap['instagram']) ?? 'https://www.instagram.com/radioteletaxi',
      youtubeUrl: _str(socialMap['youtube']) ?? 'https://www.youtube.com/@RadioTeleTaxi',
      whatsappUrl: 'https://wa.me/$whatsapp',
      streamingUrl: _str(streamingMap['url']) ?? '',
    );
  }

  /// Helper para extraer string no vacio o null.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
