import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class HomeRepository {
  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> fetchHome() async {
    return _api.getMap(Endpoints.home());
  }

  Future<Map<String, dynamic>> fetchSettings() async {
    return _api.getMap(Endpoints.settings());
  }

  Future<List<dynamic>> fetchDirecto() async {
    return _api.getList(Endpoints.directo());
  }
}
