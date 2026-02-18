import 'package:share_plus/share_plus.dart';
import 'evento_model.dart';

class EventosShare {
  EventosShare._();

  static String formatDate(Evento e) {
    final d = e.date;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  /// Cambia esto por el dominio real donde existe el evento en web
  static const String webBase = 'https://radioteletaxi.com/eventos';

  static String buildUrl(Evento e) => '$webBase/${e.id}';

  static String buildMessage(Evento e) {
    final date = formatDate(e);
    final location = e.isPrivate ? 'Privat' : e.location;
    final price = e.priceText.isEmpty ? '' : ' • ${e.priceText}';
    final url = buildUrl(e);

    return '${e.title}\n$date • $location$price\n\n$url';
  }

  static Future<void> shareEvento(Evento e) async {
    final text = buildMessage(e);
    await Share.share(text, subject: e.title);
  }
}
