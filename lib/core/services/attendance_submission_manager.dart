import 'dart:async';
import 'dart:collection';

import 'package:ams_try2/core/utils/attendance_submission_store.dart';
import 'package:ams_try2/core/utils/image_compressor.dart';
import 'package:ams_try2/features/attendance/data/attendance_file_service.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_repository_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  bool _processing = false;

  Completer<void>? _processingCompleter;

  // ---------------------------------------------------------------------------
  // Broadcast stream so multiple listeners can subscribe
  // ---------------------------------------------------------------------------
  final StreamController<SubmissionResult> _resultController =
      StreamController<SubmissionResult>.broadcast();

  Stream<SubmissionResult> get results => _resultController.stream;

  AttendanceSubmissionManager(this.ref) {
    debugPrint('🟢 Manager CREATED: ${identityHashCode(this)}');
  }

  void dispose() {
    _resultController.close();
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------
  Future<void> submitAttendance({
    required String lectureId,
    required List<String> imagePaths,
  }) async {
    // Prevent duplicate submissions
    if (_activeLectures.contains(lectureId)) {
      debugPrint('⚠️ Duplicate ignored for $lectureId');
      return;
    }

    _activeLectures.add(lectureId);

    _queue.add(
      AttendanceSubmission(
        lectureId: lectureId,
        imagePaths: List.unmodifiable(imagePaths),
      ),
    );

    debugPrint('➕ Enqueued: $lectureId');

    await _startProcessing();
  }

  // ---------------------------------------------------------------------------
  // START PROCESSING
  // ---------------------------------------------------------------------------
  Future<void> _startProcessing() async {
    // Already processing
    if (_processing) {
      return _processingCompleter?.future;
    }

    _processing = true;

    _processingCompleter = Completer<void>();

    try {
      await _processQueue();
    } finally {
      _processing = false;

      _processingCompleter?.complete();

      _processingCompleter = null;
    }
  }

  // ---------------------------------------------------------------------------
  // PROCESS QUEUE
  // ---------------------------------------------------------------------------
  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final job = _queue.first;

      try {
        await _uploadAttendance(job);

        _queue.removeFirst();

        debugPrint('✅ Removed ${job.lectureId} from queue');
      } catch (e) {
        job.attempts++;

        debugPrint(
          '❌ Upload failed for ${job.lectureId} '
          '(attempt ${job.attempts}/$_maxAttempts): $e',
        );

        // -------------------------------------------------------------------
        // MAX RETRIES EXCEEDED
        // -------------------------------------------------------------------
        if (job.attempts >= _maxAttempts) {
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
          // -------------------------------------------------------------------
          // RETRY
          // -------------------------------------------------------------------
          debugPrint(
            '🔄 Retrying ${job.lectureId} in '
            '${_retryDelay.inSeconds}s',
          );

          await Future.delayed(_retryDelay);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UPLOAD ATTENDANCE
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

      await AttendanceSubmissionStore.markSubmitted(job.lectureId);

      ref.invalidate(attendanceFilesProvider);

      _resultController.add(
        SubmissionResult(lectureId: job.lectureId, success: true),
      );
    } catch (e) {
      debugPrint('❌ REAL FAILURE: $e');

      rethrow;
    } finally {
      _activeLectures.remove(job.lectureId);

      debugPrint('🧹 Cleared active lock for ${job.lectureId}');
    }
  }
}
