import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

class Thomepage extends StatelessWidget {
  const Thomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(context, LoginPage.route());
          },
          child: const Text("Hello"),
        ),
      ),
    );
  }
}
