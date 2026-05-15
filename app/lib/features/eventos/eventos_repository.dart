import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import 'evento_model.dart';

/// Repositorio de eventos. El backend (`/app-rest/v1/eventos`) sólo expone la
/// lista completa con todos los campos por elemento; no hay endpoint
/// `/eventos/{id}`. Cacheamos la lista en memoria para resolver el detalle.
class EventosRepository {
  EventosRepository._();
  static final EventosRepository instance = EventosRepository._();

  final ApiClient _api = ApiClient.instance;

  List<Evento>? _cache;

  Future<List<Evento>> fetchEventos({bool forceRefresh = false}) async {
    final cached = _cache;
    if (cached != null && !forceRefresh) return cached;

    final data = await _api.getList(Endpoints.eventosList());
    final list = data
        .whereType<Map<String, dynamic>>()
        .map((e) => Evento.fromJson(e))
        .toList();
    _cache = list;
    return list;
  }

  /// Devuelve el evento con [id] desde cache (carga la lista si hace falta).
  /// Lanza si tras recargar tampoco se encuentra.
  Future<Evento> fetchEventoById(String id) async {
    final list = await fetchEventos();
    final found = _findById(list, id);
    if (found != null) return found;

    // Una segunda pasada con refresh por si la lista local es vieja.
    final refreshed = await fetchEventos(forceRefresh: true);
    final foundAgain = _findById(refreshed, id);
    if (foundAgain != null) return foundAgain;

    throw Exception('Evento $id no encontrado');
  }

  Evento? _findById(List<Evento> list, String id) {
    for (final e in list) {
      if (e.id.toString() == id) return e;
    }
    return null;
  }
}
