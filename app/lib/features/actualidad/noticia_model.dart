class Noticia {
  final int id;
  final String featuredImage;
  final String category;
  final String title;
  final String excerpt;
  final String content; // HTML
  final String date;    // "13/02/2026"

  Noticia({
    required this.id,
    required this.featuredImage,
    required this.category,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: (json['id'] ?? 0) is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      featuredImage: (json['featured_image'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
    );
  }
}
