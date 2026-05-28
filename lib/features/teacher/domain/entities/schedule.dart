class Schedule {
  final String lectureId;
  final String subject;
  final String courseCode;
  final String section;
  final String time;
  final String room;
  final int totalStudents;
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
    required this.lectureStatus,
    required this.attendanceMarked,
  });
}

enum LectureStatus { pending, inProgress, completed }
