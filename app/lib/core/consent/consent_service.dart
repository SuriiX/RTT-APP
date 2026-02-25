import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de consentimiento legal con persistencia local.
/// Gestiona la aceptación de Política de Privacidad, Términos de Servicio
/// y confirmación de edad (14+ LOPD-GDD).
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  static const _keyAccepted = 'rtt_consent_accepted';
  static const _keyTimestamp = 'rtt_consent_timestamp';
  static const _keyAgeConfirmed = 'rtt_consent_age_confirmed';
  static const _keyVersion = 'rtt_consent_version';

  /// Incrementar si los términos cambian para forzar re-consentimiento.
  static const int currentVersion = 1;

  bool _accepted = false;
  String? _timestamp;
  bool _ageConfirmed = false;
  int _version = 0;
  bool _loaded = false;

  /// true si el usuario completó el onboarding legal con la versión actual.
  bool get hasConsented =>
      _accepted && _ageConfirmed && _version == currentVersion;

  /// Fecha/hora ISO 8601 en que se dio el consentimiento.
  String? get consentTimestamp => _timestamp;

  /// Carga el estado de consentimiento desde SharedPreferences.
  /// Seguro de llamar múltiples veces.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _accepted = prefs.getBool(_keyAccepted) ?? false;
    _timestamp = prefs.getString(_keyTimestamp);
    _ageConfirmed = prefs.getBool(_keyAgeConfirmed) ?? false;
    _version = prefs.getInt(_keyVersion) ?? 0;
    _loaded = true;
  }

  /// Registra que el usuario aceptó los términos + privacidad + edad.
  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();

    await prefs.setBool(_keyAccepted, true);
    await prefs.setString(_keyTimestamp, now);
    await prefs.setBool(_keyAgeConfirmed, true);
    await prefs.setInt(_keyVersion, currentVersion);

    _accepted = true;
    _timestamp = now;
    _ageConfirmed = true;
    _version = currentVersion;
  }

  /// Limpia todo el consentimiento (para "Eliminar mis datos").
  Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccepted);
    await prefs.remove(_keyTimestamp);
    await prefs.remove(_keyAgeConfirmed);
    await prefs.remove(_keyVersion);

    _accepted = false;
    _timestamp = null;
    _ageConfirmed = false;
    _version = 0;
    _loaded = false;
  }
}
