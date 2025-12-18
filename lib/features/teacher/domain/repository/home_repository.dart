import '../entities/schedule.dart';

abstract class HomeRepository {
  Future<List<Schedule>> getTodaySchedule();
}
