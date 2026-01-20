import 'dart:io';

import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/dashboard/teacher_profile_page.dart';
import 'package:ams_try2/features/teacher/components/lecture_card.dart';
import 'package:ams_try2/features/teacher/components/lecture_card_shimmer.dart';
import 'package:ams_try2/features/teacher/presentation/lecture_card_mode.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/filtered_schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../providers/home_provider.dart';

class Thomepage extends ConsumerWidget {
  static Route<void> route() =>
      SlidePageRoute(child: const Thomepage(), direction: AxisDirection.left);

  const Thomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final selectedFilter = ref.watch(homeFilterProvider);
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
            onPressed: () {
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

          /// 🔹 CONTENT
          Expanded(
            child: homeState.when(
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

              data: (_) {
                /// 🔹 SEE ATTENDANCE MODE
                if (selectedFilter == HomeFilter.attendance) {
                  return const _AttendanceList();
                }

                /// 🔹 NORMAL LECTURE LIST
                if (filteredSchedules.isEmpty) {
                  return const Center(child: Text('No classes available'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(homeProvider);
                  },
                  child: ListView.builder(
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

  LectureCardMode _mapFilterToCardMode(HomeFilter filter) {
    switch (filter) {
      case HomeFilter.current:
        return LectureCardMode.current;
      case HomeFilter.attendance:
        return LectureCardMode.attendance;
      case HomeFilter.all:
        return LectureCardMode.all;
    }
  }
}

/// 🔹 FILTER CHIP
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

/// 🔹 ATTENDANCE LIST
class _AttendanceList extends ConsumerWidget {
  const _AttendanceList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(attendanceFilesProvider);

    return Column(
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Records',
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
                    await AttendanceFileUtils.clearAll(ref);
                  }
                },
              ),
            ],
          ),
        ),

        /// FILE LIST
        Expanded(
          child: filesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Failed to load attendance')),
            data: (files) {
              if (files.isEmpty) {
                return const Center(child: Text('No attendance records found'));
              }

              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (_, index) {
                  final file = files[index];
                  final name = file.path.split('/').last;
                  return _AttendanceFileTile(file: file, name: name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 🔹 FILE TILE
class _AttendanceFileTile extends StatelessWidget {
  final File file;
  final String name;

  const _AttendanceFileTile({required this.file, required this.name});

  @override
  Widget build(BuildContext context) {
    final isPdf = name.toLowerCase().endsWith('.pdf');

    return ListTile(
      leading: Icon(
        isPdf ? Icons.picture_as_pdf : Icons.table_chart,
        color: isPdf ? Colors.red : Colors.green,
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _showOpenOptions(context, file),
    );
  }
}

/// 🔹 OPEN MENU (PDF / EXCEL)
void _showOpenOptions(BuildContext context, File file) {
  final basePath = file.path.replaceAll(
    RegExp(r'\.(pdf|xlsx)$', caseSensitive: false),
    '',
  );

  final pdfFile = File('$basePath.pdf');
  final excelFile = File('$basePath.xlsx');

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Open Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          if (pdfFile.existsSync())
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Open as PDF'),
              onTap: () {
                Navigator.pop(context);
                OpenFilex.open(pdfFile.path);
              },
            ),

          if (excelFile.existsSync())
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Open as Excel'),
              onTap: () {
                Navigator.pop(context);
                OpenFilex.open(excelFile.path);
              },
            ),

          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
