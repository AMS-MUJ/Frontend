import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:ams_try2/core/utils/image_compressor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_try2/features/attendance/data/attendance_file_service.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_repository_provider.dart';
import 'package:ams_try2/core/utils/attendance_submission_store.dart';

// ---------------------------------------------------------------------------
// Result model — broadcast back to UI
// ---------------------------------------------------------------------------
class SubmissionResult {
  final String lectureId;
  final bool success;
  final String? error;

  const SubmissionResult({
    required this.lectureId,
    required this.success,
    this.error,
  });
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final attendanceSubmissionManagerProvider =
    Provider<AttendanceSubmissionManager>((ref) {
      final manager = AttendanceSubmissionManager(ref);
      final link = ref.keepAlive();
      ref.onDispose(() {
        manager.dispose();
        link.close();
      });
      return manager;
    });

// ---------------------------------------------------------------------------
// Job model
// ---------------------------------------------------------------------------
class AttendanceSubmission {
  final String lectureId;
  final List<String> imagePaths;
  int attempts;

  AttendanceSubmission({
    required this.lectureId,
    required this.imagePaths,
    this.attempts = 0,
  });
}

// ---------------------------------------------------------------------------
// Manager
// ---------------------------------------------------------------------------
class AttendanceSubmissionManager {
  static const int _maxAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 8);

  final Ref ref;
  final Queue<AttendanceSubmission> _queue = Queue();
  final Set<String> _activeLectures = {};

  // Broadcast stream so multiple listeners (cards) can subscribe
  final StreamController<SubmissionResult> _resultController =
      StreamController<SubmissionResult>.broadcast();

  Stream<SubmissionResult> get results => _resultController.stream;

  bool _processing = false;

  AttendanceSubmissionManager(this.ref) {
    debugPrint('🟢 Manager CREATED: ${identityHashCode(this)}');
  }

  void dispose() {
    _resultController.close();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------
  void submitAttendance({
    required String lectureId,
    required List<String> imagePaths,
  }) {
    if (_activeLectures.contains(lectureId)) {
      debugPrint('⚠️ Duplicate ignored for $lectureId');
      return;
    }

    _activeLectures.add(lectureId);
    _queue.add(
      AttendanceSubmission(
        lectureId: lectureId,
        imagePaths: List.unmodifiable(imagePaths), // defensive copy
      ),
    );

    debugPrint('➕ Enqueued: $lectureId');
    _startProcessing();
  }

  // ---------------------------------------------------------------------------
  // Queue processing
  // ---------------------------------------------------------------------------
  void _startProcessing() {
    if (_processing) return;
    _processing = true;
    Future.microtask(_processQueue);
  }

  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final job = _queue.first;

      try {
        await _uploadAttendance(job);
        _queue.removeFirst();
        // _activeLectures cleared inside _uploadAttendance's finally
      } catch (e) {
        job.attempts++;
        debugPrint(
          '❌ Upload failed for ${job.lectureId} '
          '(attempt ${job.attempts}/$_maxAttempts): $e',
        );

        if (job.attempts >= _maxAttempts) {
          // Give up on this job — remove from queue and active set
          _queue.removeFirst();
          _activeLectures.remove(job.lectureId);

          debugPrint('🚫 Max attempts reached for ${job.lectureId}, dropping');
          _resultController.add(
            SubmissionResult(
              lectureId: job.lectureId,
              success: false,
              error: e.toString(),
            ),
          );
        } else {
          // Keep job at front of queue, wait and retry
          await Future.delayed(_retryDelay);
        }
      }
    }

    _processing = false;
  }

  // ---------------------------------------------------------------------------
  // Upload logic
  // ---------------------------------------------------------------------------
  Future<void> _uploadAttendance(AttendanceSubmission job) async {
    debugPrint('🚀 Upload started for ${job.lectureId}');

    final repo = ref.read(attendanceRepositoryProvider);

    try {
      final compressedImages = await ImageCompressor.compressImages(
        job.imagePaths,
      );

      final result = await repo.markAttendance(job.lectureId, compressedImages);

      await AttendanceFileService.generateFiles(attendance: result);

      // ✅ Persist submission ONLY after confirmed success
      await AttendanceSubmissionStore.markSubmitted(job.lectureId);

      ref.invalidate(attendanceFilesProvider);

      debugPrint('✅ Upload completed for ${job.lectureId}');

      _resultController.add(
        SubmissionResult(lectureId: job.lectureId, success: true),
      );
    } finally {
      // Always release the lock so the lecture can be resubmitted if needed
      _activeLectures.remove(job.lectureId);
      debugPrint('🧹 Cleared active lock for ${job.lectureId}');
    }
  }
}
