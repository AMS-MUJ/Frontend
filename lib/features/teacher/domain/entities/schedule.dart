class Schedule {
  final String subject;
  final String courseCode;
  final String section;
  final String time;
  final String room;
  final int totalStudents;

  Schedule({
    required this.subject,
    required this.courseCode,
    required this.section,
    required this.time,
    required this.room,
    required this.totalStudents,
  });

  // Extract start time
  DateTime get startDateTime {
    final start = time.split('-')[0].trim(); // "10:00"
    final parts = start.split(':');
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Extract end time
  DateTime get endDateTime {
    final end = time.split('-')[1].trim(); // "11:00"
    final parts = end.split(':');
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

enum LectureStatus { pending, inProgress, completed }

extension LectureStatusX on Schedule {
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
