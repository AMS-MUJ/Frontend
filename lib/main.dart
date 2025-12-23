import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_pallete.dart';
import 'features/navigation/auth_gate.dart';
import 'features/teacher/presentation/homepage.dart';
import 'features/student/homepage.dart';

// Auth imports
import 'features/auth/data/datasource/auth_local_data_source.dart';
import 'features/auth/data/datasource/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Shared storage
import 'core/storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print(
      "Warning: .env file not found. Ensure it exists in root and is added to pubspec.yaml",
    );
  }

  // Low-level dependencies
  final client = http.Client();

  // Data sources
  final remote = AuthRemoteDataSourceImpl(client: client);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);

  // Repository & use case
  final repo = AuthRepositoryImpl(remote: remote, local: local);
  final loginUseCase = LoginUseCase(repo);

  // Auth notifier (single instance)
  final authNotifierInstance = AuthNotifier(
    loginUseCase: loginUseCase,
    repository: repo,
  );

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
    // Load cached auth once app starts
    ref.read(authNotifierProvider.notifier).loadCachedAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AMS',
      theme: appTheme,
      home: const AuthGate(),
      routes: {
        '/teacher': (_) => const Thomepage(),
        '/student': (_) => const Shomepage(),
      },
    );
  }
}
