import 'package:ams_try2/core/network/dio_client.dart';
import 'package:ams_try2/features/teacher/data/datasources/attendance_remote_data_source.dart';
import 'package:ams_try2/features/teacher/data/repositories/attendance_repository_impl.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  // watch instead of read so the repo rebuilds if dioProvider is ever
  // invalidated (e.g. after token refresh or re-auth)
  final dio = ref.watch(dioProvider);
  final remote = AttendanceRemoteDataSource(dio);
  return AttendanceRepositoryImpl(remote);
});
