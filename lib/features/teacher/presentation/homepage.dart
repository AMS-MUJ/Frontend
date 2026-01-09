import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/dashboard/teacher_profile_page.dart';
import 'package:ams_try2/features/teacher/components/lecture_card.dart';
import 'package:ams_try2/features/teacher/presentation/lecture_card_mode.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/filtered_schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';

class Thomepage extends ConsumerWidget {
  static Route<void> route() =>
      SlidePageRoute(child: const Thomepage(), direction: AxisDirection.left);

  const Thomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // API state
    final homeState = ref.watch(homeProvider);

    // Selected filter (All / Current / Upcoming)
    final selectedFilter = ref.watch(homeFilterProvider);

    // Filtered schedules (derived state)
    final filteredSchedules = ref.watch(filteredScheduleProvider);

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
            onPressed: () async {
              Navigator.push(context, TProfilePage.route());
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Classes',
                  selected: selectedFilter == HomeFilter.all,
                  onTap: () {
                    ref.read(homeFilterProvider.notifier).state =
                        HomeFilter.all;
                  },
                ),
                _FilterChip(
                  label: 'Current Class',
                  selected: selectedFilter == HomeFilter.current,
                  onTap: () {
                    ref.read(homeFilterProvider.notifier).state =
                        HomeFilter.current;
                  },
                ),
                _FilterChip(
                  label: 'Upcoming Classes',
                  selected: selectedFilter == HomeFilter.upcoming,
                  onTap: () {
                    ref.read(homeFilterProvider.notifier).state =
                        HomeFilter.upcoming;
                  },
                ),
              ],
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

              data: (_) {
                if (filteredSchedules.isEmpty) {
                  return const Center(child: Text('No classes available'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // 🔹 Force API refetch
                    ref.invalidate(homeProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredSchedules.length,
                    itemBuilder: (context, index) {
                      return LectureCard(
                        schedule: filteredSchedules[index],
                        mode: _mapFilterToCardMode(selectedFilter),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Maps HomeFilter → LectureCardMode
  LectureCardMode _mapFilterToCardMode(HomeFilter filter) {
    switch (filter) {
      case HomeFilter.current:
        return LectureCardMode.current;
      case HomeFilter.upcoming:
        return LectureCardMode.upcoming;
      case HomeFilter.all:
        return LectureCardMode.all;
    }
  }
}

/// 🔹 Reusable filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
