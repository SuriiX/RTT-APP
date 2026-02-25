import 'package:share_plus/share_plus.dart';
import 'evento_model.dart';

class EventosShare {
  EventosShare._();

  static String buildMessage(Evento e) {
    final parts = <String>[e.title];

    final dateLoc = [
      if (e.fechaInicio.isNotEmpty) e.fechaInicio,
      if (e.lugar.isNotEmpty) e.lugar,
    ];
    if (dateLoc.isNotEmpty) parts.add(dateLoc.join(' - '));

    if (e.precioDisplay.isNotEmpty) parts.add(e.precioDisplay);

    return parts.join('\n');
  }

  static Future<void> shareEvento(Evento e) async {
    final text = buildMessage(e);
    await Share.share(text, subject: e.title);
  }
}
