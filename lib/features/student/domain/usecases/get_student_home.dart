import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';

import '../repository/student_repository.dart';

class GetStudentHome {
  final StudentRepository repository;

  GetStudentHome(this.repository);

  Future<List<StudentSchedule>> call() {
    return repository.getTodaySchedule();
  }
}
