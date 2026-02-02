import 'attendance_student_model.dart';

class AttendanceModel {
  final String lectureId;
  final String fileName;
  final String message;
  final List<AttendanceStudentModel> attendance;

  AttendanceModel({
    required this.lectureId,
    required this.fileName,
    required this.message,
    required this.attendance,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      lectureId: json['lectureId'],
      fileName: json['fileName'] ?? '',
      message: json['message'] ?? '',
      attendance: (json['attendance'] as List)
          .map((e) => AttendanceStudentModel.fromJson(e))
          .toList(),
    );
  }
}
