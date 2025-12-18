import 'package:ams_try2/features/teacher/components/lecture_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';

class Thomepage extends ConsumerWidget {
  const Thomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Home',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 36),
            onPressed: () {
              debugPrint("go to dashboard");
            },
          ),
          const SizedBox(width: 15),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Classes', 'Current Class', 'Upcoming Classes']
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Chip(label: Text(e)),
                    ),
                  )
                  .toList(),
            ),
          ),

          /// 🔹 CONTENT
          Expanded(
            child: homeState.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (err, _) => Center(
                child: Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),

              data: (scheduleList) {
                if (scheduleList.isEmpty) {
                  return const Center(child: Text("No classes today"));
                }

                return ListView.builder(
                  itemCount: scheduleList.length,
                  itemBuilder: (context, index) {
                    return LectureCard(schedule: scheduleList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
