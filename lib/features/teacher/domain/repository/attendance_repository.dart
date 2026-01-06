import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Attendance> markAttendance(String lectureId, List<String> imagePaths);
}
