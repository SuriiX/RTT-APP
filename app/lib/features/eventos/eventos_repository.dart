import 'dart:convert';
import 'package:http/http.dart' as http;
import 'evento_model.dart';

class EventosRepository {
  // TODO: cambia por tu endpoint real
  final String baseUrl;

  EventosRepository({
    required this.baseUrl,
  });

  Future<List<Evento>> fetchEventos() async {
    final uri = Uri.parse('$baseUrl/eventos');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode} cargando eventos');
    }

    final data = jsonDecode(res.body);

    // Acepta lista directa o {items:[...]}
    final List items = (data is List) ? data : (data['items'] as List? ?? []);
    return items.map((e) => Evento.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Evento> fetchEventoById(String id) async {
    final uri = Uri.parse('$baseUrl/eventos/$id');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode} cargando evento $id');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return Evento.fromJson(data);
  }
}
