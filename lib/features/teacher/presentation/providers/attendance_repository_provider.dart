import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repository/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final client = http.Client();
  const baseUrl = 'http://10.0.2.2:3000/api/v1';

  final remoteDataSource = AttendanceRemoteDataSourceImpl(client, baseUrl);

  return AttendanceRepositoryImpl(remoteDataSource);
});
