import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getMap(String url) async {
    final res = await _client.get(Uri.parse(url));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Expected JSON object, got ${decoded.runtimeType}');
    }

  Future<List<dynamic>> getList(String url) async {
    final res = await _client.get(Uri.parse(url));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    if (decoded is List) return decoded;
    throw Exception('Expected JSON array, got ${decoded.runtimeType}');
  }
}
