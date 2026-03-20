import 'package:ams_try2/core/network/api_routes.dart';
import 'package:ams_try2/core/storage/secure_storage.dart';
import 'package:ams_try2/features/teacher/data/models/attendance_model.dart';
import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  Future<AttendanceModel> markAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    final token = await secureStorage.read(key: 'token');

    final formData = FormData();

    // Attach all images to the same multipart request
    for (final path in imagePaths) {
      formData.files.add(
        MapEntry("images", await MultipartFile.fromFile(path)),
      );
    }

    final response = await dio.post(
      '${ApiRoutes.markAttendance}/$lectureId',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Attendance upload failed');
    }

    return AttendanceModel.fromJson(response.data);
  }
}
