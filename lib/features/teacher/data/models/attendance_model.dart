import '../../domain/entities/attendance.dart';

class AttendanceModel {
  final String lectureId;
  final String fileName;
  final String subject;
  final String date;
  final List<StudentAttendance> students;

  AttendanceModel({
    required this.lectureId,
    required this.fileName,
    required this.subject,
    required this.date,
    required this.students,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      lectureId: json['lectureId'],
      fileName: json['fileName'],
      subject: json['subject'],
      date: json['date'],
      students: (json['students'] as List)
          .map(
            (s) => StudentAttendance(
              rollNo: s['rollNo'],
              name: s['name'],
              present: s['present'],
            ),
          )
          .toList(),
    );
  }

  Attendance toEntity() => Attendance(
    lectureId: lectureId,
    fileName: fileName,
    subject: subject,
    date: date,
    students: students,
  );
}
