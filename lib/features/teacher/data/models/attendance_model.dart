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
    return AttendanceModel(
      lectureId: json['lectureId'] ?? '',
      message: json['message'] ?? '',
      fileName: json['fileName'] ?? '',
      attendance: (json['attendance'] as List)
          .map((e) => AttendanceRow.fromJson(e))
          .toList(),
    );
  }
}
