import 'package:ams_try2/features/navigation/auth_gate.dart';
import 'package:ams_try2/features/teacher/presentation/homepage.dart';
import 'package:ams_try2/features/teacher/providers/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SplashPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(homeProvider, (_, state) {
      state.whenData((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthGate()),
        );
      });
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
