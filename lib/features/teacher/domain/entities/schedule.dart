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
  final LectureStatus lectureStatus;
  final bool attendanceMarked;

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
    required this.lectureStatus,
  });
}
