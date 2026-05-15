import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

/// Repositorio de la pantalla Home. Compone los datos del directo, una
/// muestra de actualidad y los próximos eventos a partir de los endpoints
/// REST del plugin `rtt-app-api`.
class HomeRepository {
  final ApiClient _api = ApiClient.instance;

  /// Programa actual en directo. Lista de máximo 1 elemento.
  Future<List<dynamic>> fetchDirecto() async {
    return _api.getList(Endpoints.directo());
  }

  /// Top N noticias para el carrusel de la home.
  Future<List<dynamic>> fetchActualidadTop({int perPage = 6}) async {
    final m =
        await _api.getMap(Endpoints.actualidadList(page: 1, perPage: perPage));
    final news = m['news'];
    return news is List ? news : const <dynamic>[];
  }

  /// Próximos eventos para el carrusel de "Entradas a la venta".
  Future<List<dynamic>> fetchEventosTop({int max = 8}) async {
    final l = await _api.getList(Endpoints.eventosList());
    return l.take(max).toList();
  }
}
