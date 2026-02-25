import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
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
  final ApiClient _api = ApiClient.instance;

  Future<ActualidadResponse> fetchActualidad({
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Endpoints.actualidadList(page: page, perPage: perPage);
    final data = await _api.getMap(url);

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
