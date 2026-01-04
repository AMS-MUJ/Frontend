class Attendance {
  final String lectureId;
  final String fileName;
  final String subject;
  final String date;
  final List<StudentAttendance> students;

  Attendance({
    required this.lectureId,
    required this.fileName,
    required this.subject,
    required this.date,
    required this.students,
  });
}

class StudentAttendance {
  final String rollNo;
  final String name;
  final bool present;

  StudentAttendance({
    required this.rollNo,
    required this.name,
    required this.present,
  });
}
