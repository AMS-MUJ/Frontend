import 'package:ams_try2/core/services/attendance_submission_manager.dart';
import 'package:ams_try2/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_pallete.dart';

// Auth imports
import 'features/auth/data/datasource/auth_local_data_source.dart';
import 'features/auth/data/datasource/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Shared storage
import 'core/storage/secure_storage.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ dotenv load failed: ${e.toString()}');
  }

  // Low-level dependencies
  final client = http.Client();

  // Data sources
  final remote = AuthRemoteDataSourceImpl(client: client);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);

  // Repository & use case
  final repo = AuthRepositoryImpl(remote: remote, local: local);
  final loginUseCase = LoginUseCase(repo);

  runApp(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(
          (ref) => AuthNotifier(
            ref: ref,
            loginUseCase: loginUseCase,
            repository: repo,
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
/// This ensures long-running services start BEFORE UI renders.
/// Very important for background uploads.
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔴 Create the submission manager immediately
    // Now it belongs to the ProviderContainer (app lifetime)
    ref.read(attendanceSubmissionManagerProvider);

    // Also load cached auth
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
