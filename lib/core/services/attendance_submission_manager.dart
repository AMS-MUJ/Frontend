import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:ams_try2/core/utils/image_compressor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_try2/features/attendance/data/attendance_file_service.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_repository_provider.dart';

/// ---------------------------------------------------------------------------
/// GLOBAL APPLICATION SERVICE
/// ---------------------------------------------------------------------------

final attendanceSubmissionManagerProvider =
    Provider<AttendanceSubmissionManager>((ref) {
      final manager = AttendanceSubmissionManager(ref);

      final link = ref.keepAlive();
      ref.onDispose(() {
        link.close();
      });

      return manager;
    });

/// ---------------------------------------------------------------------------
/// Job Entity
/// ---------------------------------------------------------------------------
class AttendanceSubmission {
  final String lectureId;
  final List<String> imagePaths;

  AttendanceSubmission({required this.lectureId, required this.imagePaths});
}

/// ---------------------------------------------------------------------------
/// Submission Manager
/// ---------------------------------------------------------------------------
class AttendanceSubmissionManager {
  final Ref ref;

  final Queue<AttendanceSubmission> _queue = Queue();

  /// 🔴 Prevent duplicate submissions
  final Set<String> _activeLectures = {};

  bool _processing = false;

  AttendanceSubmissionManager(this.ref) {
    debugPrint("🟢 Manager CREATED: ${identityHashCode(this)}");
  }

  /// Called by UI
  void submitAttendance({
    required String lectureId,
    required List<String> imagePaths,
  }) {
    debugPrint("📩 submitAttendance called for $lectureId");

    // 🔴 Prevent duplicate submission
    if (_activeLectures.contains(lectureId)) {
      debugPrint("⚠️ Duplicate ignored for $lectureId");
      return;
    }

    _activeLectures.add(lectureId);

    _queue.add(
      AttendanceSubmission(lectureId: lectureId, imagePaths: imagePaths),
    );

    debugPrint("➕ Added to queue: $lectureId");

    _startProcessing();
  }

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
      } catch (e) {
        debugPrint("❌ Upload failed for ${job.lectureId}, retrying...");
        await Future.delayed(const Duration(seconds: 8));
      }
    }

    _processing = false;
  }

  Future<void> _uploadAttendance(AttendanceSubmission job) async {
    debugPrint("🚀 Upload started for ${job.lectureId}");

    final repo = ref.read(attendanceRepositoryProvider);

    try {
      final compressedImages = await ImageCompressor.compressImages(
        job.imagePaths,
      );

      final result = await repo.markAttendance(job.lectureId, compressedImages);

      await AttendanceFileService.generateFiles(attendance: result);

      ref.invalidate(attendanceFilesProvider);

      debugPrint("✅ Upload completed for ${job.lectureId}");
    } finally {
      _activeLectures.remove(job.lectureId);
      debugPrint("🧹 Cleared active state for ${job.lectureId}");
    }
  }
}
