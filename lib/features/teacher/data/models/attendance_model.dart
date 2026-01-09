import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_row.dart';

class AttendanceModel extends Attendance {
  AttendanceModel({
    required super.lectureId,
    required super.message,
    required super.fileName,
    required super.attendance,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final rawAttendance = json['attendance'];

    return AttendanceModel(
      lectureId: json['lectureId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      attendance: rawAttendance is List
          ? rawAttendance.map((e) => AttendanceRow.fromJson(e)).toList()
          : [],
    );
  }
}
