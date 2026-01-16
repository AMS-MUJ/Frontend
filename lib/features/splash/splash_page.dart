import 'package:ams_try2/features/student/presentation/pages/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/slide_page_route.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../auth/presentation/pages/login_page.dart';
import '../teacher/presentation/homepage.dart';
import '../student/homepage.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      /// 🔹 Run tasks in parallel
      await Future.wait([
        ref.read(authNotifierProvider.notifier).loadCachedAuth(),
        Future.delayed(const Duration(milliseconds: 400)), // UX smoothness
      ]);

      if (!mounted) return;

      final authState = ref.read(authNotifierProvider);

      /// 🔹 Decide navigation
      if (authState.auth == null) {
        _go(const LoginPage());
        return;
      }

      final role = authState.auth!.user.role.toLowerCase();

      if (role == 'teacher') {
        _go(const Thomepage());
      } else {
        _go(const StudentHomePage());
      }
    } catch (e, stack) {
      /// -Absolute safety net
      debugPrint('Splash bootstrap error: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;
      _go(const LoginPage());
    }
  }

  void _go(Widget page) {
    Navigator.pushReplacement(context, SlidePageRoute(child: page));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
