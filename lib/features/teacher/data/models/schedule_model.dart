import '../../domain/entities/schedule.dart';

class ScheduleModel {
  final String lectureId;
  final String subject;
  final String courseCode;
  final String section;
  final String time;
  final String room;
  final int totalStudents;

  // 🔐 attendance status (from dashboard OR status API)
  final bool attendanceMarked;
  final DateTime? attendanceMarkedAt;

  ScheduleModel({
    required this.lectureId,
    required this.subject,
    required this.courseCode,
    required this.section,
    required this.time,
    required this.room,
    required this.totalStudents,
    required this.attendanceMarked,
    required this.attendanceMarkedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      lectureId: json['lectureId'] as String,
      subject: json['subject'] as String,
      courseCode: json['courseCode'] as String,
      section: json['section_name'] as String,
      time: json['time'] as String,
      room: json['room'] as String,
      totalStudents: json['totalStudents'] as int,

      // 🔐 attendance lock (safe defaults)
      attendanceMarked: json['attendanceMarked'] ?? false,
      attendanceMarkedAt: json['attendanceMarkedAt'] != null
          ? DateTime.parse(json['attendanceMarkedAt'])
          : null,
    );
  }

  Schedule toEntity() {
    final parts = time.split('-');
    final start = _parseTime(parts[0].trim());
    final end = _parseTime(parts[1].trim());

    return Schedule(
      lectureId: lectureId,
      subject: subject,
      courseCode: courseCode,
      section: section,
      time: time,
      room: room,
      totalStudents: totalStudents,
      startDateTime: start,
      endDateTime: end,
      attendanceMarked: attendanceMarked,
      attendanceMarkedAt: attendanceMarkedAt,
    );
  }

  DateTime _parseTime(String t) {
    final now = DateTime.now();
    final parts = t.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
