import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.auth?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(user.name, style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 20),

            Text('Email', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(user.email, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
