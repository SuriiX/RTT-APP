import 'dart:convert';
import 'package:http/http.dart' as http;
import 'entrada_model.dart';

class EntradasRepository {
  final String baseUrl;

  EntradasRepository({required this.baseUrl});

  Future<List<Entrada>> fetchEntradas() async {
    final uri = Uri.parse('$baseUrl/entradas');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode} cargando entradas');
    }

    final data = jsonDecode(res.body);
    final List items = (data is List) ? data : (data['items'] as List? ?? []);
    return items.map((e) => Entrada.fromJson(e as Map<String, dynamic>)).toList();
  }
}
