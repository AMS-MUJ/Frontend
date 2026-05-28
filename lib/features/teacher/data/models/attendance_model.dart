import 'attendance_student_model.dart';

class AttendanceModel {
  final String sectionId;
  final String date;
  final String markedBy;

  final int total;
  final int present;
  final int absent;

  final List<AttendanceStudentModel> attendance;

  AttendanceModel({
    required this.sectionId,
    required this.date,
    required this.markedBy,
    required this.total,
    required this.present,
    required this.absent,
    required this.attendance,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      sectionId: json['section_id'] ?? '',

      date: json['date'] ?? '',

      markedBy: json['marked_by'] ?? '',

      total: json['total'] ?? 0,

      present: json['present'] ?? 0,

      absent: json['absent'] ?? 0,

      attendance: (json['attendance'] as List<dynamic>? ?? [])
          .map(
            (e) => AttendanceStudentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
