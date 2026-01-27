import 'package:ams_try2/core/config/app_config.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/create_class/data/datasources/create_class_remote_ds.dart';
import 'package:ams_try2/features/create_class/data/repositories/create_class_repo_impl.dart';
import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';
import 'package:ams_try2/features/create_class/domain/usecase/create_class_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_sections_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_subjects_usecase.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_notifier.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final dioProvider = Provider<Dio>((ref) {
//   return Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
// });
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authNotifierProvider).auth?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});

final createClassRepoProvider = Provider<CreateClassRepository>((ref) {
  final dio = ref.read(dioProvider);
  return CreateClassRepositoryImpl(CreateClassRemoteDSImpl(dio));
});

final createClassNotifierProvider =
    StateNotifierProvider<CreateClassNotifier, CreateClassState>((ref) {
      final repo = ref.read(createClassRepoProvider);
      return CreateClassNotifier(
        GetSubjects(repo),
        GetSections(repo),
        CreatePermanentClass(repo),
        CreateTemporaryClass(repo),
      );
    });
