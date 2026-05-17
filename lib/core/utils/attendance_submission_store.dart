import 'package:shared_preferences/shared_preferences.dart';

class AttendanceSubmissionStore {
  AttendanceSubmissionStore._();

  static const String _prefix = 'attendance_submitted_';
  static const String _failCountPrefix = 'attendance_fail_count_';

  static String _key(String lectureId) => '$_prefix$lectureId';
  static String _failKey(String lectureId) => '$_failCountPrefix$lectureId';

  // ---------------------------------------------------------------------------
  // Core submission state
  // ---------------------------------------------------------------------------

  static Future<void> markSubmitted(String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key(lectureId), true);
      // Clear any lingering fail count on success
      await prefs.remove(_failKey(lectureId));
    } catch (e) {
      // SharedPreferences failure must never crash the caller.
      // The manager already confirmed upload success — losing the local
      // persistence flag is acceptable; worst case the card re-enables
      // submission on next app launch (safe — backend will deduplicate).
      assert(false, 'AttendanceSubmissionStore.markSubmitted failed: $e');
    }
  }

  static Future<bool> isSubmitted(String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key(lectureId)) ?? false;
    } catch (_) {
      return false; // fail open — let the teacher retry rather than locking them out
    }
  }

  // ---------------------------------------------------------------------------
  // Failure tracking (lets UI show a retry-exhausted banner)
  // ---------------------------------------------------------------------------

  static Future<void> recordFailure(String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_failKey(lectureId)) ?? 0;
      await prefs.setInt(_failKey(lectureId), current + 1);
    } catch (_) {}
  }

  static Future<int> failureCount(String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_failKey(lectureId)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk helpers
  // ---------------------------------------------------------------------------

  static Future<void> clearForLecture(String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_key(lectureId)),
        prefs.remove(_failKey(lectureId)),
      ]);
    } catch (_) {}
  }

  /// Returns every lectureId that has been marked submitted.
  /// Useful for a debug/admin screen or re-hydrating state after reinstall.
  static Future<List<String>> allSubmittedLectureIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs
          .getKeys()
          .where((k) => k.startsWith(_prefix) && prefs.getBool(k) == true)
          .map((k) => k.substring(_prefix.length))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Wipes all attendance submission data — use only in tests or on sign-out.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs
          .getKeys()
          .where((k) => k.startsWith(_prefix) || k.startsWith(_failCountPrefix))
          .toList();
      await Future.wait(keysToRemove.map(prefs.remove));
    } catch (_) {}
  }
}
