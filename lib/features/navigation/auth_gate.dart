import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/student/homepage.dart';
import 'package:ams_try2/features/teacher/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.auth == null) {
      return const LoginPage();
    }

    final role = authState.auth!.user.role.toLowerCase();
    if (role == 'teacher') {
      return const Thomepage();
    } else {
      return const Shomepage();
    }
  }
}
