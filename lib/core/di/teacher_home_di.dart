import 'package:ams_try2/core/network/api_client.dart';
import 'package:ams_try2/features/teacher/data/datasources/home_remote_datasource.dart';
import 'package:ams_try2/features/teacher/data/repositories/home_repository_impl.dart';
import 'package:ams_try2/features/teacher/domain/repository/home_repository.dart';
import 'package:ams_try2/features/teacher/domain/usecase/get_today_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1️⃣ ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// 2️⃣ Remote Datasource Provider
final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider); // VALUE, not provider
  return HomeRemoteDatasource(apiClient);
});

//fake data source provider
// final homeDatasourceProvider = Provider<HomeDatasource>((ref) {
//   return HomeFakeDatasource(); // ✅ works
// });

/// 3️⃣ Repository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final datasource = ref.read(homeRemoteDatasourceProvider);
  return HomeRepositoryImpl(datasource);
});

/// 4️⃣ UseCase Provider
final getScheduleUsecaseProvider = Provider<GetTodaySchedule>((ref) {
  final repository = ref.read(homeRepositoryProvider);
  return GetTodaySchedule(repository);
});
