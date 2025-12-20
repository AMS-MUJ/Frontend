import 'package:ams_try2/core/network/api_routes.dart';
import './home_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../models/schedule_model.dart';

class HomeRemoteDatasource implements HomeDatasource {
  final ApiClient apiClient;

  HomeRemoteDatasource(this.apiClient);

  @override
  Future<List<ScheduleModel>> fetchSchedule() async {
    final response = await apiClient.get(ApiRoutes.teacherDashboard);
    final List list = response['schedule'];
    return list.map((e) => ScheduleModel.fromJson(e)).toList();
  }
}
