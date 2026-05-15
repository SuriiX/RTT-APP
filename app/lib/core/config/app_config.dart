/// Configuración corporativa de RadioTeleTaxi.
///
/// Antes se cargaba dinámicamente desde `/rtt-app/v1/settings`, pero ese
/// endpoint nunca llegó a quedar bien (devolvía la URL de streaming como
/// placeholder `mdstrm_XXXXX.com`). Los plugins WordPress actuales
/// (`rtt-app-api` + `rtt-mediastream`) no exponen un equivalente.
///
/// La URL del stream se resuelve ahora vía `Endpoints.streamAndroid()`
/// (el servidor responde con un 302 a la URL real de Mediastream).
/// El resto de datos son constantes corporativas estables.
class AppConfig {
  AppConfig._();

  /// Instancia singleton.
  static final AppConfig instance = AppConfig._();

  /// Teléfono de antena en directo (formato e164 sin "+").
  String get phoneNumber => '934661819';

  /// WhatsApp del programa.
  String get whatsappNumber => '34646212121';

  String get facebookUrl => 'https://www.facebook.com/RadioTeleTaxi';
  String get twitterUrl => 'https://twitter.com/RadioTeleTaxi';
  String get instagramUrl => 'https://www.instagram.com/radioteletaxi';
  String get youtubeUrl => 'https://www.youtube.com/@RadioTeleTaxi';
  String get whatsappUrl => 'https://wa.me/$whatsappNumber';
}
