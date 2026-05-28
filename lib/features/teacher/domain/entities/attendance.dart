import 'attendance_row.dart';

class Attendance {
  final String sectionId;

  final String date;

  final String markedBy;

  final int total;

  final int present;

  final int absent;

  final List<AttendanceRow> attendance;

  Attendance({
    required this.sectionId,

    required this.date,

    required this.markedBy,

    required this.total,

    required this.present,

    required this.absent,

    required this.attendance,
  });
}
