import 'package:ams_try2/core/network/dio_client.dart';
import 'package:ams_try2/core/storage/secure_storage.dart';
import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/student_remote_datasource.dart';
import '../../data/repository/student_repository_impl.dart';
import '../../domain/usecases/get_student_home.dart';

/// Provides centralized Dio
final dioProvider = Provider<Dio>((ref) {
  return DioClient(secureStorage: secureStorage).dio;
});

/// Provides StudentRemoteDatasource
final studentRemoteDatasourceProvider = Provider<StudentRemoteDatasource>((
  ref,
) {
  final dio = ref.read(dioProvider);

  return StudentRemoteDatasource(dio);
});

/// Provides StudentRepository
final studentRepositoryProvider = Provider<StudentRepositoryImpl>((ref) {
  final datasource = ref.read(studentRemoteDatasourceProvider);

  return StudentRepositoryImpl(datasource);
});

/// Provides UseCase
final getStudentHomeUsecaseProvider = Provider<GetStudentHome>((ref) {
  final repository = ref.read(studentRepositoryProvider);

  return GetStudentHome(repository);
});

/// FINAL PROVIDER USED BY UI
final studentHomeProvider = FutureProvider<List<StudentSchedule>>((ref) async {
  final usecase = ref.read(getStudentHomeUsecaseProvider);

  return await usecase();
});
