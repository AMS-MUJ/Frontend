import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:flutter/material.dart';

class LectureCard extends StatelessWidget {
  final Schedule schedule;

  const LectureCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.subject,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("${schedule.courseCode} • Section ${schedule.section}"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("🕘 ${schedule.time}"),
                Text("👥 ${schedule.totalStudents}"),
                Text("📍 ${schedule.room}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
