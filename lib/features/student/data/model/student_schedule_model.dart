import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';

class StudentScheduleModel extends StudentSchedule {
  StudentScheduleModel({
    required super.subject,
    required super.time,
    required super.room,
    required super.status,
  });

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudentScheduleModel(
      subject: json['subject'],
      time: json['time'],
      room: json['room'],
      status: json['status'],
    );
  }
}
