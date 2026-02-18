class Entrada {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String priceText;
  final String imageUrl;
  final String buyUrl;
  final bool soldOut;

  Entrada({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.priceText,
    required this.imageUrl,
    required this.buyUrl,
    required this.soldOut,
  });

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory Entrada.fromJson(Map<String, dynamic> json) {
    return Entrada(
      id: json['id'].toString(),
      title: (json['title'] ?? json['titulo'] ?? '').toString(),
      date: _parseDate(json['date'] ?? json['fecha']),
      location: (json['location'] ?? json['lugar'] ?? '').toString(),
      priceText: (json['price_text'] ?? json['precio'] ?? '').toString(),
      imageUrl: (json['image'] ?? json['imagen'] ?? '').toString(),
      buyUrl: (json['buy_url'] ?? json['url_compra'] ?? '').toString(),
      soldOut: (json['sold_out'] ?? json['agotado'] ?? false) == true,
    );
  }
}
