import '../../domain/entities/attendance_row.dart';

class AttendanceStudentModel {
  final String regNo;
  final String name;
  final String status;

  AttendanceStudentModel({
    required this.regNo,
    required this.name,
    required this.status,
  });

  factory AttendanceStudentModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStudentModel(
      regNo: json['regNo'],
      name: json['name'],
      status: json['status'],
    );
  }

  AttendanceRow toEntity() {
    return AttendanceRow(regNo: regNo, name: name, status: status);
  }
}
