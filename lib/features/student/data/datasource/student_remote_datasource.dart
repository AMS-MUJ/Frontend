import 'package:ams_try2/core/network/api_routes.dart';
import 'package:dio/dio.dart';

class StudentRemoteDatasource {
  final Dio dio;

  StudentRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> getStudentHome() async {
    final response = await dio.get(ApiRoutes.studentDashboard);

    return response.data;
  }
}
