import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Shomepage extends ConsumerWidget {
  const Shomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();

            // 2️⃣ CLEAR STACK & GO TO LOGIN
            Navigator.pushAndRemoveUntil(
              context,
              LoginPage.route(),
              (_) => false,
            );
          },
          child: const Text("Logout from student"),
        ),
      ),
    );
  }
}
