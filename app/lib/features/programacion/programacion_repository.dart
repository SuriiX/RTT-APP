import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class ProgramacionRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<dynamic>> fetchProgramacion() async {
    return _api.getList(Endpoints.programacion());
  }
}
