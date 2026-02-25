import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import 'evento_model.dart';

class EventosRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Evento>> fetchEventos() async {
    final data = await _api.getList(Endpoints.eventosList());

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Evento.fromJson(e))
        .toList();
  }

  Future<Evento> fetchEventoById(String id) async {
    final data = await _api.getMap(Endpoints.eventoById(id));
    return Evento.fromJson(data);
  }
}
