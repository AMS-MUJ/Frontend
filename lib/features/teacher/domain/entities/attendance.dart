import 'attendance_row.dart';

class Attendance {
  final String lectureId;
  final String fileName;
  final String message;
  final List<AttendanceRow> attendance;

  Attendance({
    required this.lectureId,
    required this.fileName,
    required this.message,
    required this.attendance,
  });
}
