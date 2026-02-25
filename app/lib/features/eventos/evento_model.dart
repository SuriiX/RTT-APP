class Evento {
  final int id;
  final String title;
  final String featuredImage;
  final String featuredImageThumbnail;
  final String fechaInicio; // "19/02/2026"
  final String fechaFin;
  final String mes; // "Febrero"
  final String any; // "2026"
  final String lugar;
  final String direccion;
  final String hora;
  final String precio;
  final String content; // HTML
  final bool agotadas;
  final bool proximamenteALaVenta;
  final bool tieneEntradas;
  final String linkCompra;
  final bool gestionadoPorRtt;
  final bool aPartirDe;

  Evento({
    required this.id,
    required this.title,
    required this.featuredImage,
    required this.featuredImageThumbnail,
    required this.fechaInicio,
    required this.fechaFin,
    required this.mes,
    required this.any,
    required this.lugar,
    required this.direccion,
    required this.hora,
    required this.precio,
    required this.content,
    required this.agotadas,
    required this.proximamenteALaVenta,
    required this.tieneEntradas,
    required this.linkCompra,
    required this.gestionadoPorRtt,
    required this.aPartirDe,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: _parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      featuredImage: (json['featured_image'] ?? '').toString(),
      featuredImageThumbnail: (json['featured_image_thumbnail'] ?? '').toString(),
      fechaInicio: (json['fecha_inicio'] ?? '').toString(),
      fechaFin: (json['fecha_fin'] ?? '').toString(),
      mes: (json['mes'] ?? '').toString(),
      any: (json['any'] ?? '').toString(),
      lugar: (json['lugar'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      hora: (json['hora'] ?? '').toString(),
      precio: (json['precio'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      agotadas: json['agotadas'] == true,
      proximamenteALaVenta: json['proximamente_a_la_venta'] == true,
      tieneEntradas: json['tiene_entradas'] == true,
      linkCompra: (json['link_compra_de_entrada'] ?? '').toString(),
      gestionadoPorRtt: json['gestionado_por_radioteletaxi'] == true,
      aPartirDe: json['a_partir_de'] == true,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Texto de precio formateado (ej: "A partir de 23€" o "10€")
  String get precioDisplay {
    if (precio.isEmpty) return '';
    if (aPartirDe) return 'A partir de $precio';
    return precio;
  }
}
