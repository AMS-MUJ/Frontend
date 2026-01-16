import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';

abstract class StudentRepository {
  Future<List<StudentSchedule>> getTodaySchedule();
}
