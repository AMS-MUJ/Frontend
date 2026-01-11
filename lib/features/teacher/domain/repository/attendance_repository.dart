import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Attendance> markAttendance(String lectureId, List<String> imagePaths);
}
