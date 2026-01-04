import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ams_try2/core/storage/attendance_storage.dart';
import 'package:ams_try2/core/utils/excel_helper.dart';

import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance_files.dart';
import 'package:ams_try2/features/teacher/domain/repository/attendance_repository.dart';

import 'attendance_di_provider.dart';

/// =============================================================
/// 🔹 STATE
/// =============================================================
class AttendanceState {
  final bool submitting;
  final bool submitted;
  final List<String> photoPaths;
  final Attendance? attendance;

  const AttendanceState({
    this.submitting = false,
    this.submitted = false,
    this.photoPaths = const [],
    this.attendance,
  });

  AttendanceState copyWith({
    bool? submitting,
    bool? submitted,
    List<String>? photoPaths,
    Attendance? attendance,
  }) {
    return AttendanceState(
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      photoPaths: photoPaths ?? this.photoPaths,
      attendance: attendance ?? this.attendance,
    );
  }
}

/// =============================================================
/// 🔹 NOTIFIER
/// =============================================================
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository repository;
  final String lectureId;

  AttendanceNotifier(this.repository, this.lectureId)
    : super(const AttendanceState());

  /// 📸 Add a photo path (max handled in UI)
  void addPhoto(String path) {
    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
  }

  /// 🚀 Submit attendance
  Future<void> submit() async {
    if (state.submitted || state.submitting) return;

    state = state.copyWith(submitting: true);

    try {
      /// 1️⃣ Upload attendance (API / mock)
      final Attendance result = await repository.uploadAttendance(lectureId);

      /// 2️⃣ Generate Excel file locally
      await generateAttendanceExcel(result);

      /// 3️⃣ Save metadata for Profile page
      await saveAttendanceFile(
        AttendanceFile(
          lectureId: result.lectureId,
          fileName: result.fileName,
          date: result.date,
        ),
      );

      /// 4️⃣ Update state
      state = state.copyWith(
        submitting: false,
        submitted: true,
        attendance: result,
      );
    } catch (e) {
      state = state.copyWith(submitting: false);
      rethrow;
    }
  }

  /// 🧹 Clear state (optional)
  void clear() {
    state = const AttendanceState();
  }

  void removePhoto(int index) {
    final updated = [...state.photoPaths]..removeAt(index);
    state = state.copyWith(photoPaths: updated);
  }
}

/// =============================================================
/// 🔹 PROVIDER (PER LECTURE)
/// =============================================================
final attendanceProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>((
      ref,
      lectureId,
    ) {
      final AttendanceRepository repository = ref.read(
        attendanceRepositoryProvider,
      );

      return AttendanceNotifier(repository, lectureId);
    });
