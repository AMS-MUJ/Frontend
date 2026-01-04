import 'package:http/http.dart' as http;

import '../models/attendance_model.dart';

class AttendanceRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AttendanceRemoteDataSource(this.client, this.baseUrl);

  Future<AttendanceModel> uploadAttendance({required String lectureId}) async {
    // ⏳ MOCK RESPONSE (API not ready)
    await Future.delayed(const Duration(seconds: 2));

    return AttendanceModel.fromJson({
      "lectureId": lectureId,
      "fileName": "Daa_02_Jan.xlsx",
      "subject": "Cryptography",
      "date": "2026-01-01",
      "students": [
        {"rollNo": "CSE01", "name": "Aman", "present": true},
        {"rollNo": "CSE02", "name": "Riya", "present": false},
      ],
    });
  }
}
