import 'package:ams_try2/core/network/api_client.dart';
import 'package:ams_try2/core/network/api_routes.dart';

class StudentRemoteDatasource {
  final ApiClient apiClient;

  StudentRemoteDatasource(this.apiClient);

  Future<Map<String, dynamic>> getStudentHome() async {
    // ApiClient already returns decoded JSON
    final response = await apiClient.get(ApiRoutes.studentDashboard);

    return response;
  }
}
