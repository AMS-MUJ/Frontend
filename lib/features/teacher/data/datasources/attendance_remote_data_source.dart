import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> markAttendance(
    String lectureId,
    List<String> imagePaths,
  );
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AttendanceRemoteDataSourceImpl(this.client, this.baseUrl);

  @override
  Future<AttendanceModel> markAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/attendance/mark-face/$lectureId'),
    );
    print('🟡 POST $request');
    print('🟡 photos count: ${imagePaths.length}');

    for (final path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', path));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return AttendanceModel.fromJson(jsonDecode(body));
    } else {
      throw Exception('Attendance submission failed');
    }
  }
}
