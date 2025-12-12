// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_pallete.dart';

// Data source

// Repository + usecase + provider
import 'features/auth/data/datasource/auth_local_data_source.dart';
import 'features/auth/data/datasource/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usercase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Pages
import 'features/auth/presentation/pages/login_page.dart';

// Simple placeholder home pages (replace with your real pages)
class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Home')),
      body: const Center(child: Text('Teacher Home')),
    );
  }
}

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Home')),
      body: const Center(child: Text('Student Home')),
    );
  }
}

void main() {
  // --- Create low-level dependencies ---
  final client = http.Client();
  const baseUrl = 'https://your-api.com'; // <-- update to your backend
  final secureStorage = const FlutterSecureStorage();

  // --- Create data sources ---
  final remote = AuthRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);

  // --- Create repository & use case ---
  final repo = AuthRepositoryImpl(remote: remote, local: local);
  final loginUseCase = LoginUseCase(repo);

  // --- Create the AuthNotifier instance (kept alive for app lifetime) ---
  final authNotifier = AuthNotifier(
    loginUseCase: loginUseCase,
    repository: repo,
  );

  // --- Run app with ProviderScope and override the provider ---
  runApp(
    ProviderScope(
      overrides: [
        // Correct Riverpod 2.x override: overrideWith takes a builder that receives ref.
        authNotifierProvider.overrideWith((ref) => authNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ams_try2',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/teacher': (context) => const TeacherHomePage(),
        '/student': (context) => const StudentHomePage(),
      },
    );
  }
}
