import 'package:ams_try2/features/teacher/data/datasources/attendance_remote_data_source.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remote;

  AttendanceRepositoryImpl(this.remote);

  @override
  Future<Attendance> markAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    final model = await remote.markAttendance(lectureId, imagePaths);

    return Attendance(
      lectureId: model.lectureId,
      fileName: model.fileName,
      message: model.message,
      attendance: model.attendance.map((m) => m.toEntity()).toList(),
    );
  }
}
