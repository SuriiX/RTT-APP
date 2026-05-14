import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class FrecuenciasRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<dynamic>> fetchFrecuencias() async {
    return _api.getList(Endpoints.frecuencias());
  }
}
