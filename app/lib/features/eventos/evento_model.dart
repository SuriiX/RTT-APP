class Evento {
  final String id;
  final DateTime date;
  final String title;
  final String location;
  final String priceText; // "10€" o "Desde 23€"
  final String imageUrl;
  final bool isPrivate;

  Evento({
    required this.id,
    required this.date,
    required this.title,
    required this.location,
    required this.priceText,
    required this.imageUrl,
    required this.isPrivate,
  });

  static DateTime _parseDate(dynamic v) {
    // acepta "2026-02-27" o ISO
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'].toString(),
      date: _parseDate(json['date'] ?? json['fecha']),
      title: (json['title'] ?? json['titulo'] ?? '').toString(),
      location: (json['location'] ?? json['lugar'] ?? 'Privat').toString(),
      priceText: (json['price_text'] ?? json['precio'] ?? '').toString(),
      imageUrl: (json['image'] ?? json['imagen'] ?? '').toString(),
      isPrivate: (json['private'] ?? json['privado'] ?? false) == true,
    );
  }
}
