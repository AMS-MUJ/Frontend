import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_try2/features/attendance/data/attendance_file_service.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_repository_provider.dart';

/// ---------------------------------------------------------------------------
/// GLOBAL APPLICATION SERVICE
/// ---------------------------------------------------------------------------
/// This is NOT UI state.
/// This is a long-running background job manager.
/// It must live for the entire app lifetime.

final attendanceSubmissionManagerProvider =
    Provider<AttendanceSubmissionManager>((ref) {
      final manager = AttendanceSubmissionManager(ref);

      // Prevent Riverpod from garbage collecting the manager
      final link = ref.keepAlive();
      ref.onDispose(link.close);

      return manager;
    });

/// ---------------------------------------------------------------------------
/// Job Entity
/// ---------------------------------------------------------------------------
class AttendanceSubmission {
  final String lectureId;
  final String imagePath;

  AttendanceSubmission({required this.lectureId, required this.imagePath});
}

/// ---------------------------------------------------------------------------
/// Submission Manager (Background Worker Queue)
/// ---------------------------------------------------------------------------
class AttendanceSubmissionManager {
  final Ref ref;

  /// FIFO queue
  final Queue<AttendanceSubmission> _queue = Queue();

  /// Prevent multiple workers
  bool _processing = false;

  AttendanceSubmissionManager(this.ref);

  /// Called by UI
  /// UI does NOT upload — it only enqueues
  void submitAttendance({
    required String lectureId,
    required String imagePath,
  }) {
    _queue.add(
      AttendanceSubmission(lectureId: lectureId, imagePath: imagePath),
    );

    _startProcessing();
  }

  /// Starts worker safely
  void _startProcessing() {
    if (_processing) return;

    _processing = true;

    // detach from widget lifecycle
    Future.microtask(_processQueue);
  }

  /// Core worker loop
  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final job = _queue.first;

      try {
        await _uploadAttendance(job);

        // success -> remove job
        _queue.removeFirst();
      } catch (e) {
        // network/server failure -> retry
        await Future.delayed(const Duration(seconds: 8));
      }
    }

    _processing = false;
  }

  /// Real upload lives ONLY here
  Future<void> _uploadAttendance(AttendanceSubmission job) async {
    final repo = ref.read(attendanceRepositoryProvider);

    // Upload a single image
    final result = await repo.uploadSingleImage(job.lectureId, job.imagePath);

    // Generate files locally after backend success
    await AttendanceFileService.generateFiles(attendance: result);

    // Refresh dashboard / file list UI
    ref.invalidate(attendanceFilesProvider);
  }
}
