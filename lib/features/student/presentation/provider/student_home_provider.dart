import 'package:ams_try2/core/network/api_client.dart';
import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/student_remote_datasource.dart';
import '../../data/repository/student_repository_impl.dart';
import '../../domain/usecases/get_student_home.dart';

/// Provides ApiClient (core layer)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides StudentRemoteDatasource
final studentRemoteDatasourceProvider = Provider<StudentRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return StudentRemoteDatasource(apiClient);
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

/// 🔥 FINAL PROVIDER USED BY UI
final studentHomeProvider = FutureProvider<List<StudentSchedule>>((ref) async {
  final usecase = ref.read(getStudentHomeUsecaseProvider);
  return await usecase();
});
