import 'attendance_row.dart';

class Attendance {
  final String lectureId;
  final String message;
  final String fileName;
  final List<AttendanceRow> attendance;

  Attendance({
    required this.lectureId,
    required this.message,
    required this.fileName,
    required this.attendance,
  });
}
