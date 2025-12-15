import 'package:ams_try2/features/teacher/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_pallete.dart';
import 'features/auth/data/datasource/auth_local_data_source.dart';
import 'features/auth/data/datasource/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usercase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/student/homepage.dart';
import 'features/navigation/auth_gate.dart';

void main() {
  // --- Create low-level dependencies ---
  final client = http.Client();
  const baseUrl = 'http://10.0.2.2:5000/api/v1'; // <-- update to your backend
  final secureStorage = const FlutterSecureStorage();

  // --- Create data sources ---
  final remote = AuthRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);

  // --- Create repository & use case ---
  final repo = AuthRepositoryImpl(remote: remote, local: local);
  final loginUseCase = LoginUseCase(repo);

  // --- Create the AuthNotifier instance (kept alive for app lifetime) ---
  final authNotifierInstance = AuthNotifier(
    loginUseCase: loginUseCase,
    repository: repo,
  );

  // --- 5. Run app with ProviderScope and override the provider ---
  runApp(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => authNotifierInstance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authNotifierProvider.notifier).loadCachedAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ams_try2',
      theme: appTheme,
      home: const AuthGate(),
      routes: {
        '/teacher': (_) => const Thomepage(),
        '/student': (_) => const Shomepage(),
      },
    );
  }
}
