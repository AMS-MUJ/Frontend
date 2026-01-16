import 'dart:convert';
import 'package:ams_try2/core/storage/secure_storage.dart';
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
      '${AppConfig.baseUrl}${ApiRoutes.markAttendance}/$lectureId',
    );

    final token = await secureStorage.read(key: 'token');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    for (final path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Attendance submission failed');
    }

    return AttendanceModel.fromJson(jsonDecode(response.body));
  }
}
