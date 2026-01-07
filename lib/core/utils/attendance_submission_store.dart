import 'package:shared_preferences/shared_preferences.dart';

class AttendanceSubmissionStore {
  static String _key(String lectureId) => 'attendance_submitted_$lectureId';

  /// ✅ Mark lecture as submitted
  static Future<void> markSubmitted(String lectureId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(lectureId), true);
  }

  /// ✅ Check if lecture already submitted
  static Future<bool> isSubmitted(String lectureId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(lectureId)) ?? false;
  }
}
