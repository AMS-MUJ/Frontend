import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Attendance> uploadAttendance(String lectureId);
}
