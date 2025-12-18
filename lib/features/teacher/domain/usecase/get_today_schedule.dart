import '../repository/home_repository.dart';
import '../entities/schedule.dart';

class GetTodaySchedule {
  final HomeRepository repository;

  GetTodaySchedule(this.repository);

  Future<List<Schedule>> call() {
    return repository.getTodaySchedule();
  }
}
