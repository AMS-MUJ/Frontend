import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter_provider.dart';
import 'package:ams_try2/features/teacher/providers/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredScheduleProvider = Provider<AsyncValue<List<Schedule>>>((ref) {
  final filter = ref.watch(homeFilterProvider);
  final schedulesAsync = ref.watch(homeProvider);

  return schedulesAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (schedules) {
      List<Schedule> filtered;

      switch (filter) {
        case HomeFilter.all:
          filtered = schedules;
          break;

        case HomeFilter.current:
          // Uses backend-provided lectureStatus — no device clock needed
          filtered = schedules
              .where((s) => s.lectureStatus == LectureStatus.inProgress)
              .toList();
          break;

        case HomeFilter.attendance:
          filtered = schedules.where((s) => s.attendanceMarked).toList();
          break;
      }

      return AsyncData(filtered);
    },
  );
});
