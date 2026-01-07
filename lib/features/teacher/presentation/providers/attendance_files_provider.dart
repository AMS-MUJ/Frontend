import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// 📂 Provider to list all attendance Excel files
final attendanceFilesProvider = FutureProvider<List<File>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.xlsx'))
      .toList();
});

/// 🧹 Attendance file utilities
class AttendanceFileUtils {
  static Future<void> clearAll(WidgetRef ref) async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.xlsx'),
    );

    for (final file in files) {
      await file.delete();
    }

    /// 🔄 Refresh provider so UI updates
    ref.invalidate(attendanceFilesProvider);
  }
}
