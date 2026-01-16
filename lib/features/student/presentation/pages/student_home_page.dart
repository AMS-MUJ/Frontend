import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/student_home_provider.dart';
import '../widgets/class_card.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(studentHomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Classes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: homeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(e.toString().replaceAll('Exception: ', ''))),
          data: (schedule) {
            if (schedule.isEmpty) {
              return const Center(
                child: Text("No classes scheduled for today"),
              );
            }

            return ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (_, i) {
                final s = schedule[i];
                return ClassCard(
                  subject: s.subject,
                  time: s.time,
                  room: s.room,
                  status: s.status,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
