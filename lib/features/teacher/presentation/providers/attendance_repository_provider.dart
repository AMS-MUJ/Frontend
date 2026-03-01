import 'package:ams_try2/features/create_class/presentation/providers/create_class_provider.dart';
import 'package:ams_try2/features/teacher/data/datasources/attendance_remote_data_source.dart';
import 'package:ams_try2/features/teacher/data/repositories/attendance_repository_impl.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dio = ref.read(dioProvider);

  final remote = AttendanceRemoteDataSource(dio);

  return AttendanceRepositoryImpl(remote);
});