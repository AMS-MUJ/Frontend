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

    final response = await dio.post(
      '${ApiRoutes.markAttendance}/$lectureId',
      data: formData,

      // IMPORTANT
      options: Options(extra: {'isMultipart': true, 'imagePaths': imagePaths}),
    );

    if (response.statusCode != 200) {
      throw Exception('Attendance upload failed');
    }

    return AttendanceModel.fromJson(response.data);
  }
}
