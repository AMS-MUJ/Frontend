import 'package:ams_try2/features/teacher/providers/attendance_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ✅ Provider declaration (TOP LEVEL ONLY)
final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>(
      (ref, lectureId) => AttendanceNotifier(),
    );

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(const AttendanceState());

  void addPhoto(String path) {
    if (state.photoPaths.length >= 6) return;

    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
  }

  void submit() {
    state = state.copyWith(submitted: true);
  }

  void clear() {
    state = const AttendanceState();
  }
}
