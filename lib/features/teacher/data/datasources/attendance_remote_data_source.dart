import 'package:ams_try2/core/network/api_routes.dart';
import 'package:ams_try2/features/teacher/data/models/attendance_model.dart';
import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  Future<AttendanceModel> markAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    final formData = FormData();

    // Attach images
    for (final path in imagePaths) {
      formData.files.add(
        MapEntry("images", await MultipartFile.fromFile(path)),
      );
    }

    // Save original connectTimeout and temporarily increase it
    // for cold-start protection on the ML endpoint
    final originalConnectTimeout = dio.options.connectTimeout;
    dio.options.connectTimeout = const Duration(minutes: 2);

    try {
      final response = await dio.post(
        '${ApiRoutes.markAttendance}/$lectureId',
        data: formData,

        // IMPORTANT — extended timeouts for ML processing + server cold-starts
        options: Options(
          extra: {'isMultipart': true, 'imagePaths': imagePaths},
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Attendance upload failed');
      }

      return AttendanceModel.fromJson(response.data);
    } finally {
      // Restore original connectTimeout
      dio.options.connectTimeout = originalConnectTimeout;
    }
  }
}
