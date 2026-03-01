import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Attendance> uploadSingleImage(String lectureId, String imagePath);
}
