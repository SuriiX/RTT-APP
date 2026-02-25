import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._() : _client = http.Client();

  static final ApiClient instance = ApiClient._();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  /// GET que devuelve un Map<String, dynamic>.
  Future<Map<String, dynamic>> getMap(String url) async {
    final decoded = await _get(url);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('Se esperaba un objeto JSON, se recibió ${decoded.runtimeType}');
  }

  /// GET que devuelve una List<dynamic>.
  Future<List<dynamic>> getList(String url) async {
    final decoded = await _get(url);
    if (decoded is List) return decoded;
    throw ApiException('Se esperaba una lista JSON, se recibió ${decoded.runtimeType}');
  }

  /// GET raw que devuelve http.Response (para repos que necesitan headers).
  Future<http.Response> getRaw(String url) async {
    try {
      final res = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Error del servidor (${res.statusCode})');
      }
      return res;
    } on SocketException {
      throw ApiException('Sin conexión a internet');
    } on TimeoutException {
      throw ApiException('La petición tardó demasiado (timeout)');
    }
  }

  /// GET interno con parseo JSON.
  Future<dynamic> _get(String url) async {
    try {
      final res = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Error del servidor (${res.statusCode})');
      }
      return json.decode(utf8.decode(res.bodyBytes));
    } on SocketException {
      throw ApiException('Sin conexión a internet');
    } on TimeoutException {
      throw ApiException('La petición tardó demasiado (timeout)');
    } on FormatException catch (e) {
      debugPrint('JSON parse error: $e');
      throw ApiException('Respuesta inválida del servidor');
    }
  }
}

/// Excepción tipada para errores de API con mensaje legible.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
