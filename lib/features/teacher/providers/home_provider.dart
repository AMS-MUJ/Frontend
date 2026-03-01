import 'package:ams_try2/core/di/teacher_home_di.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeProvider = FutureProvider<List<Schedule>>((ref) async {
  final authState = ref.watch(authNotifierProvider);

  // 🔒 BLOCK until auth is ready
  if (authState.auth == null) {
    throw Exception('AUTH_NOT_READY');
  }

  final getSchedule = ref.read(getScheduleUsecaseProvider);
  return getSchedule();
});
