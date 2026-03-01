import 'package:ams_try2/features/attendance/data/attendance_cleanup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/attendance/domain/attendance_record.dart';
import 'package:ams_try2/features/dashboard/teacher_profile_page.dart';
import 'package:ams_try2/features/teacher/components/lecture_card.dart';
import 'package:ams_try2/features/teacher/components/lecture_card_shimmer.dart';
import 'package:ams_try2/features/teacher/presentation/lecture_card_mode.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/filtered_schedule_provider.dart';

import '../providers/home_provider.dart';

class Thomepage extends ConsumerWidget {
  static Route<void> route() =>
      SlidePageRoute(child: const Thomepage(), direction: AxisDirection.left);

  const Thomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(homeFilterProvider);
    final schedulesAsync = ref.watch(filteredScheduleProvider);

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
            icon: const Icon(Icons.menu, size: 36),
            onPressed: () {
              Navigator.push(context, TProfilePage.route());
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Current Class',
                  selected: selectedFilter == HomeFilter.current,
                  onTap: () => ref.read(homeFilterProvider.notifier).state =
                      HomeFilter.current,
                ),
                _FilterChip(
                  label: 'All Classes',
                  selected: selectedFilter == HomeFilter.all,
                  onTap: () => ref.read(homeFilterProvider.notifier).state =
                      HomeFilter.all,
                ),
                _FilterChip(
                  label: 'See Attendance',
                  selected: selectedFilter == HomeFilter.attendance,
                  onTap: () => ref.read(homeFilterProvider.notifier).state =
                      HomeFilter.attendance,
                ),
              ],
            ),
          ),

          /// MAIN CONTENT
          Expanded(
            child: schedulesAsync.when(
              loading: () => ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => const LectureCardShimmer(),
              ),
              error: (err, _) => Center(
                child: Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (schedules) {
                if (selectedFilter == HomeFilter.attendance) {
                  return const _AttendanceList();
                }

                if (schedules.isEmpty) {
                  return const Center(child: Text('No classes available'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(homeProvider);
                  },
                  child: ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return LectureCard(
                        schedule: schedules[index],
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

  LectureCardMode _mapFilterToCardMode(HomeFilter filter) {
    switch (filter) {
      case HomeFilter.current:
        return LectureCardMode.current;
      case HomeFilter.all:
        return LectureCardMode.all;
      case HomeFilter.attendance:
        return LectureCardMode.attendance;
    }
  }
}

/// FILTER CHIP
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

/// ATTENDANCE LIST (EXCEL ONLY)
class _AttendanceList extends ConsumerWidget {
  const _AttendanceList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(attendanceFilesProvider);

    return Column(
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Excel Files',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear Attendance'),
                      content: const Text(
                        'This will permanently delete all attendance files.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    await AttendanceCleanupService.clearAll();
                    ref.invalidate(attendanceFilesProvider);
                  }
                },
              ),
            ],
          ),
        ),

        /// RECORD LIST
        Expanded(
          child: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Failed to load attendance')),
            data: (records) {
              if (records.isEmpty) {
                return const Center(child: Text('No attendance records found'));
              }

              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (_, index) {
                  final record = records[index];
                  final name = record.excelPath.split('/').last;

                  return ListTile(
                    leading: const Icon(Icons.table_chart, color: Colors.green),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openExcel(context, record),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// OPEN EXCEL
void _openExcel(BuildContext context, AttendanceRecord record) {
  OpenFilex.open(record.excelPath);
}
