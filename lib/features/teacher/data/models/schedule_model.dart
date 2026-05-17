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
    required super.startDateTime,
    required super.endDateTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      lectureId: json['schedule_id']?.toString() ?? '',
      subject: json['subject_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      section: json['section_name'] ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
      totalStudents: json['total_students'] ?? 0,
      lectureStatus: _parseStatus(json['status']),
      attendanceMarked: json['is_marked'] ?? false,
      startDateTime: null,
      endDateTime: null,
    );
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
