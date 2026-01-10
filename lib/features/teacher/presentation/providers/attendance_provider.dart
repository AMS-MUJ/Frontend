import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final String lectureId;

  AttendanceNotifier(this.repo, this.lectureId) : super(AttendanceState());

  Future<void> submitAttendance(List<String> imagePaths) async {
    try {
      state = state.copyWith(loading: true, error: null);

      final result = await repo.markAttendance(lectureId, imagePaths);

      state = state.copyWith(
        loading: false,
        attendance: result, //  KEEP THE DATA
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> checkIsMarked() {
    return repo.isMarked(lectureId);
  }
}

final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>((
      ref,
      lectureId,
    ) {
      final repo = ref.read(attendanceRepositoryProvider);
      return AttendanceNotifier(repo, lectureId);
    });
