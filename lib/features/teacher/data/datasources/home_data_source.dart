import '../models/schedule_model.dart';

abstract class HomeDatasource {
  Future<List<ScheduleModel>> fetchSchedule();
}
