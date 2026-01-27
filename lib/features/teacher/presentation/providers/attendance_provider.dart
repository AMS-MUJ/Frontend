import 'package:ams_try2/features/attendance/data/attendance_file_service.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'attendance_files_provider.dart';
import 'attendance_repository_provider.dart';

class AttendanceState {
  final bool loading;
  final Attendance? attendance;
  final String? error;

  AttendanceState({this.loading = false, this.attendance, this.error});

  AttendanceState copyWith({
    bool? loading,
    Attendance? attendance,
    String? error,
  }) {
    return AttendanceState(
      loading: loading ?? this.loading,
      attendance: attendance ?? this.attendance,
      error: error,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository repo;
  final Ref ref;
  final String lectureId;

  AttendanceNotifier(this.repo, this.ref, this.lectureId)
    : super(AttendanceState());

  Future<void> submitAttendance(List<String> imagePaths) async {
    try {
      state = state.copyWith(loading: true, error: null);

      // 1️⃣ Backend → JSON
      final result = await repo.markAttendance(lectureId, imagePaths);

      if (result.attendance.isEmpty) {
        throw Exception('No attendance rows received');
      }

      // 2️⃣ JSON → PDF/Excel (LOCAL)
      await AttendanceFileService.generateFiles(attendance: result);

      // 3️⃣ Refresh file-based UI
      ref.invalidate(attendanceFilesProvider);

      // 4️⃣ Update state
      state = state.copyWith(loading: false, attendance: result, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// ✅ THIS IS WHAT YOUR UI IS LOOKING FOR
final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>((
      ref,
      lectureId,
    ) {
      final repo = ref.read(attendanceRepositoryProvider);
      return AttendanceNotifier(repo, ref, lectureId);
    });
