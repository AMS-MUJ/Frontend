import 'package:ams_try2/core/services/attendance_submission_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AttendanceStatus { idle, inProgress, success, failed }

class AttendanceState {
  final AttendanceStatus status;
  final String? error;

  const AttendanceState({this.status = AttendanceStatus.idle, this.error});

  AttendanceState copyWith({AttendanceStatus? status, String? error}) {
    return AttendanceState(
      status: status ?? this.status,
      error: status == AttendanceStatus.idle ? null : (error ?? this.error),
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref ref;
  final String lectureId;

  AttendanceNotifier(this.ref, this.lectureId) : super(const AttendanceState());

  Future<void> submitAttendance(List<String> imagePaths) async {
    if (state.status == AttendanceStatus.inProgress ||
        state.status == AttendanceStatus.success) {
      return;
    }

    state = state.copyWith(status: AttendanceStatus.inProgress, error: null);

    try {
      ref
          .read(attendanceSubmissionManagerProvider)
          .submitAttendance(lectureId: lectureId, imagePaths: imagePaths);
      state = state.copyWith(status: AttendanceStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.failed,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const AttendanceState();
}

final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>(
      (ref, lectureId) => AttendanceNotifier(ref, lectureId),
    );
