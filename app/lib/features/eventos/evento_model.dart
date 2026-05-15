/// Modelo de Evento que mapea el JSON devuelto por
/// `https://radioteletaxi.com/app-rest/v1/eventos`.
///
/// El plugin `rtt-app-api` devuelve fechas como `dd/mm/yyyy` (no ISO) y
/// expone todos los detalles en cada elemento de la lista (no hay endpoint
/// `/eventos/{id}`). Por eso este modelo conserva el HTML/strings tal cual.
class Evento {
  final String id;

  // Fecha de inicio (DateTime cuando se pudo parsear) + texto original.
  final DateTime date;
  final String dateText;
  final String dateEndText;
  final String monthText; // p.ej. "Junio"
  final String yearText; // p.ej. "2026"

  final String title;
  final String location;
  final String address;
  final String hourText;
  final String priceText;
  final String imageUrl;
  final String thumbnailUrl;

  // HTML largo del cuerpo (puede estar vacío).
  final String contentHtml;

  // Flags del CRUD del cliente.
  final bool isPrivate;
  final bool hasTickets;
  final bool soldOut;
  final bool comingSoon;
  final bool managedByRtt;
  final bool fromPrice;
  final String purchaseUrl;

  Evento({
    required this.id,
    required this.date,
    required this.dateText,
    required this.dateEndText,
    required this.monthText,
    required this.yearText,
    required this.title,
    required this.location,
    required this.address,
    required this.hourText,
    required this.priceText,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.contentHtml,
    required this.isPrivate,
    required this.hasTickets,
    required this.soldOut,
    required this.comingSoon,
    required this.managedByRtt,
    required this.fromPrice,
    required this.purchaseUrl,
  });

  static DateTime _parseFlexibleDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    final s = v.toString().trim();
    if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    // Formato "dd/mm/yyyy".
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2,4})').firstMatch(s);
    if (m != null) {
      final dd = int.tryParse(m.group(1)!) ?? 1;
      final mm = int.tryParse(m.group(2)!) ?? 1;
      var yy = int.tryParse(m.group(3)!) ?? 1970;
      if (yy < 100) yy += 2000;
      return DateTime(yy, mm, dd);
    }

    // Fallback ISO.
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      return v == '1' || v.toLowerCase() == 'true';
    }
    return false;
  }

  static String _asString(dynamic v) => (v ?? '').toString();

  factory Evento.fromJson(Map<String, dynamic> json) {
    final fechaInicio = _asString(json['fecha_inicio'] ?? json['date']);
    final fechaFin = _asString(json['fecha_fin']);
    return Evento(
      id: _asString(json['id']),
      date: _parseFlexibleDate(fechaInicio),
      dateText: fechaInicio,
      dateEndText: fechaFin,
      monthText: _asString(json['mes']),
      yearText: _asString(json['any']),
      title: _asString(json['title'] ?? json['titulo']),
      location: _asString(json['lugar'] ?? json['location']),
      address: _asString(json['direccion']),
      hourText: _asString(json['hora']),
      priceText: _asString(json['precio'] ?? json['price_text']),
      imageUrl: _asString(
          json['featured_image'] ?? json['image'] ?? json['imagen']),
      thumbnailUrl: _asString(
          json['featured_image_thumbnail'] ?? json['featured_image']),
      contentHtml: _asString(json['content']),
      isPrivate: _asBool(json['private'] ?? json['privado']),
      hasTickets: _asBool(json['tiene_entradas']),
      soldOut: _asBool(json['agotadas']),
      comingSoon: _asBool(json['proximamente_a_la_venta']),
      managedByRtt: _asBool(json['gestionado_por_radioteletaxi']),
      fromPrice: _asBool(json['a_partir_de']),
      purchaseUrl: _asString(json['link_compra_de_entrada']),
    );
  }
}
