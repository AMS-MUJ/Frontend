import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_routes.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDataSource {
  Future<AttendanceModel> markAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    final uri = Uri.parse(
      '${AppConfig.mockApiUrl}${ApiRoutes.markAttendance}/$lectureId',
    );

    final request = http.MultipartRequest('POST', uri);

    for (final path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('🔵 MARK ATTENDANCE RESPONSE');
    debugPrint('🔵 STATUS CODE: ${response.statusCode}');
    debugPrint('🔵 BODY: ${response.body}');

    if (response.statusCode != 200) {
      final errorJson = jsonDecode(response.body);
      throw Exception(errorJson['message'] ?? 'Attendance submission failed');
    }

    return AttendanceModel.fromJson(jsonDecode(response.body));
  }

  Future<bool> isMarked(String lectureId) async {
    final uri = Uri.parse(
      '${AppConfig.mockApiUrl}${ApiRoutes.isMarked}/$lectureId',
    );

    final response = await http.get(uri);

    debugPrint('🔵 IS MARKED RESPONSE');
    debugPrint('🔵 STATUS CODE: ${response.statusCode}');
    debugPrint('🔵 BODY: ${response.body}');

    if (response.statusCode != 200) {
      final errorJson = jsonDecode(response.body);
      throw Exception(
        errorJson['message'] ?? 'Failed to check attendance status',
      );
    }

    final json = jsonDecode(response.body);
    return json['marked'] == true;
  }
}
