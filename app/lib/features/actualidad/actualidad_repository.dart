import 'dart:convert';
import 'package:http/http.dart' as http;
import 'noticia_model.dart';

class ActualidadResponse {
  final List<Noticia> news;
  final int totalPages;
  final int total;

  ActualidadResponse({
    required this.news,
    required this.totalPages,
    required this.total,
  });
}

class ActualidadRepository {
  final String baseUrl; // ej: https://radioteletaxi.com/app-rest/v1

  ActualidadRepository({required this.baseUrl});

  Future<ActualidadResponse> fetchActualidad({
    int page = 1,
    int perPage = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/actualidadv2?page=$page&per_page=$perPage');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode} cargando actualidad');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final headers = (data['headers'] as Map?)?.cast<String, dynamic>() ?? {};
    final totalPages = int.tryParse((headers['x-wp-totalpages'] ?? '1').toString()) ?? 1;
    final total = int.tryParse((headers['x-wp-total'] ?? '0').toString()) ?? 0;

    final List items = (data['news'] as List? ?? []);
    final news = items
        .map((e) => Noticia.fromJson(e as Map<String, dynamic>))
        .toList();

    return ActualidadResponse(news: news, totalPages: totalPages, total: total);
  }
}
