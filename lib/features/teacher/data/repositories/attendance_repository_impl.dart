import '../../domain/entities/attendance.dart';
import '../../domain/repository/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remote;

  AttendanceRepositoryImpl(this.remote);

  @override
  Future<Attendance> uploadAttendance(String lectureId) async {
    final model = await remote.uploadAttendance(lectureId: lectureId);
    return model.toEntity();
  }
}
