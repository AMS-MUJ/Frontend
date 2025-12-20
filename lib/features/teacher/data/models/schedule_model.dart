class ScheduleModel {
  final String id;
  final String subject;
  final String courseCode;
  final String section;
  final String time;
  final String room;
  final String status;
  final int totalStudents;

  ScheduleModel({
    required this.id,
    required this.subject,
    required this.courseCode,
    required this.section,
    required this.time,
    required this.room,
    required this.status,
    required this.totalStudents,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      courseCode: json['courseCode'] ?? '',
      section: json['section'] ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
      status: json['status'] ?? '',
      totalStudents: json['totalStudents'] ?? '',
    );
  }
}
