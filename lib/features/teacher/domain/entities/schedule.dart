enum LectureStatus { pending, inProgress, completed }

class Schedule {
  final String lectureId;
  final String subject;
  final String courseCode;
  final String section;
  final String time;
  final String room;
  final int totalStudents;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool attendanceMarked;
  final DateTime? attendanceMarkedAt;

  const Schedule({
    required this.lectureId,
    required this.subject,
    required this.courseCode,
    required this.section,
    required this.time,
    required this.room,
    required this.totalStudents,
    required this.startDateTime,
    required this.endDateTime,
    required this.attendanceMarked,
    required this.attendanceMarkedAt,
  });

  /// 🔹 Derived lecture status (single source of truth)
  LectureStatus get lectureStatus {
    final now = DateTime.now();

    if (now.isBefore(startDateTime)) {
      return LectureStatus.pending;
    } else if (now.isAfter(endDateTime)) {
      return LectureStatus.completed;
    } else {
      return LectureStatus.inProgress;
    }
  }
}
