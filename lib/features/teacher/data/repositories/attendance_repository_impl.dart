import '../../domain/entities/attendance.dart';
import '../../domain/repository/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Attendance> markAttendance(String lectureId, List<String> imagePaths) {
    return remoteDataSource.markAttendance(lectureId, imagePaths);
  }
}
