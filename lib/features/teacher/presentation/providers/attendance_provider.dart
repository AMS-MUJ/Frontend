import 'package:ams_try2/core/services/attendance_submission_manager.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_repository_provider.dart';

/// ---------------- STATUS ----------------
enum AttendanceStatus { idle, inProgress, success, failed }

/// ---------------- STATE ----------------
class AttendanceState {
  final AttendanceStatus status;
  final Attendance? attendance;
  final String? error;

  AttendanceState({
    this.status = AttendanceStatus.idle,
    this.attendance,
    this.error,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    Attendance? attendance,
    String? error,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      attendance: attendance ?? this.attendance,
      error: error,
    );
  }
}

/// ---------------- NOTIFIER ----------------
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository repo;
  final Ref ref;
  final String lectureId;

  AttendanceNotifier(this.repo, this.ref, this.lectureId)
    : super(AttendanceState());

  Future<void> submitAttendance(List<String> imagePaths) async {
    // 🔴 CORE FIX: STATUS GUARD
    if (state.status == AttendanceStatus.inProgress ||
        state.status == AttendanceStatus.success) {
      return;
    }

    try {
      // 🔴 mark as in progress BEFORE doing anything
      state = state.copyWith(status: AttendanceStatus.inProgress, error: null);

      final manager = ref.read(attendanceSubmissionManagerProvider);

      manager.submitAttendance(lectureId: lectureId, imagePaths: imagePaths);

      // 🔴 we mark success because job is accepted (not completed)
      state = state.copyWith(status: AttendanceStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.failed,
        error: e.toString(),
      );
    }
  }
}

/// ---------------- PROVIDER ----------------
final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>((
      ref,
      lectureId,
    ) {
      final repo = ref.read(attendanceRepositoryProvider);
      return AttendanceNotifier(repo, ref, lectureId);
    });
