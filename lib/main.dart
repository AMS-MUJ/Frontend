import 'package:ams_try2/core/services/attendance_submission_manager.dart';
import 'package:ams_try2/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:ams_try2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ams_try2/features/auth/domain/usecases/login_usecase.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/splash/splash_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_pallete.dart';
import 'core/network/dio_client.dart';

// Auth imports
import 'package:ams_try2/features/auth/data/datasource/auth_local_data_source.dart';

// Shared storage
import 'core/storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ dotenv load failed: ${e.toString()}');
  }

  /// 🔥 Initialize ONE Dio instance (shared globally)
  final dioClient = DioClient(secureStorage: secureStorage);
  final Dio dio = dioClient.dio;

  /// 🔐 Local data source (uses same secure storage)
  final authLocal = AuthLocalDataSourceImpl(secureStorage: secureStorage);

  /// 🌐 Remote data source
  final authRemote = AuthRemoteDataSourceImpl(dio: dio);

  /// 🧠 Repository
  final authRepo = AuthRepositoryImpl(remote: authRemote, local: authLocal);

  /// 🎯 Usecase
  final loginUseCase = LoginUseCase(authRepo);

  runApp(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(
          (ref) => AuthNotifier(
            ref: ref,
            loginUseCase: loginUseCase,
            repository: authRepo,
          ),
        ),
      ],
      child: const AppBootstrap(),
    ),
  );
}

/// ------------------------------------------------------------
/// BOOTSTRAP
/// ------------------------------------------------------------
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 🔴 Start background services immediately
    ref.read(attendanceSubmissionManagerProvider);

    /// 🔐 Load cached auth (token + user)
    ref.read(authNotifierProvider.notifier).loadCachedAuth();

    return const MyApp();
  }
}

/// ------------------------------------------------------------
/// MAIN APP UI
/// ------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AMS',
      theme: appTheme,
      home: SplashPage(),
    );
  }
}
