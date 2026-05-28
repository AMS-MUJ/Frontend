import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.lectureId,
    required super.subject,
    required super.courseCode,
    required super.section,
    required super.time,
    required super.room,
    required super.totalStudents,
    required super.lectureStatus,
    required super.attendanceMarked,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      lectureId: json['schedule_id'] ?? '',
      subject: json['course_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      section: json['section'] ?? '',
      time: _formatTime(json['start_time'], json['end_time']),
      room: json['room'] ?? '',
      totalStudents: json['student_count'] ?? 0,
      lectureStatus: _parseStatus(json['status']), // ← backend-provided
      attendanceMarked: json['is_marked'] ?? false,
    );
  }

  static String _formatTime(String? start, String? end) {
    if (start == null && end == null) return '';
    if (end == null) return start ?? '';
    return '$start - $end';
  }

  static LectureStatus _parseStatus(String? status) {
    switch (status) {
      case 'in_progress':
        return LectureStatus.inProgress;
      case 'completed':
        return LectureStatus.completed;
      default:
        return LectureStatus.pending;
    }
  }
}
