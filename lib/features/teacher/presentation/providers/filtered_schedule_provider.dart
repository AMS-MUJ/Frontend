import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter.dart';
import 'package:ams_try2/features/teacher/presentation/providers/home_filter_provider.dart';
import 'package:ams_try2/features/teacher/providers/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredScheduleProvider = Provider<List<Schedule>>((ref) {
  final filter = ref.watch(homeFilterProvider);
  final schedulesAsync = ref.watch(homeProvider);

  return schedulesAsync.maybeWhen(
    data: (schedules) {
      final now = DateTime.now();

      switch (filter) {
        case HomeFilter.all:
          return schedules;

        case HomeFilter.current:
          return schedules.where((s) {
            return now.isAfter(s.startDateTime) && now.isBefore(s.endDateTime);
          }).toList();

        case HomeFilter.upcoming:
          return schedules.where((s) {
            return s.startDateTime.isAfter(now);
          }).toList();
      }
    },
    orElse: () => [],
  );
});
