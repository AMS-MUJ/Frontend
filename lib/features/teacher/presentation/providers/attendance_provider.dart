import 'package:ams_try2/features/teacher/presentation/providers/attendance_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';

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
  final AttendanceRepository repository;

  AttendanceNotifier(this.repository) : super(AttendanceState());

  Future<void> submitAttendance(
    String lectureId,
    List<String> imagePaths,
  ) async {
    state = state.copyWith(loading: true);
    try {
      final attendance = await repository.markAttendance(lectureId, imagePaths);
      state = state.copyWith(loading: false, attendance: attendance);
    } catch (e, s) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      final repository = ref.read(attendanceRepositoryProvider); // KEY LINE
      return AttendanceNotifier(repository);
    });
