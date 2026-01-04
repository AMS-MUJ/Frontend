import 'package:ams_try2/features/teacher/data/datasources/attendance_remote_data_source.dart';
import 'package:ams_try2/features/teacher/data/repositories/attendance_repository_impl.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';

/// 🔹 HTTP CLIENT
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// 🔹 REMOTE DATASOURCE
final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>(
  (ref) {
    final client = ref.read(httpClientProvider);
    return AttendanceRemoteDataSource(
      client,
      AppConfig.baseUrl, // now matches constructor
    );
  },
);

/// 🔹 REPOSITORY
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final remote = ref.read(attendanceRemoteDataSourceProvider);
  return AttendanceRepositoryImpl(remote);
});
