import 'package:ams_try2/core/di/teacher_home_di.dart';
import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeProvider = FutureProvider<List<Schedule>>((ref) async {
  final usecase = ref.read(getScheduleUsecaseProvider);
  return usecase();
});
