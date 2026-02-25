import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import 'evento_model.dart';

class EventosRepository {
  final _api = ApiClient();

  Future<List<Evento>> fetchEventos() async {
    final data = await _api.getList(Endpoints.eventos());
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Evento.fromJson(e))
        .toList();
  }

  /// La API no tiene /eventos/:id, así que buscamos en la lista completa.
  Future<Evento?> fetchEventoById(int id) async {
    final eventos = await fetchEventos();
    for (final e in eventos) {
      if (e.id == id) return e;
    }
    return null;
  }
}
