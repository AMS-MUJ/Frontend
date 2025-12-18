import './home_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../models/schedule_model.dart';

class HomeRemoteDatasource implements HomeDatasource {
  final ApiClient apiClient;

  HomeRemoteDatasource(this.apiClient);

  @override
  Future<List<ScheduleModel>> fetchSchedule() async {
    final res = await apiClient.get("YOUR_API_URL");
    final List list = res['schedule'];
    return list.map((e) => ScheduleModel.fromJson(e)).toList();
  }
}
