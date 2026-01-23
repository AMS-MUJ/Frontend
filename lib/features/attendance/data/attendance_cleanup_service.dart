import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AttendanceCleanupService {
  static Future<void> clearAll() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.pdf') || f.path.endsWith('.xlsx'),
    );

    for (final file in files) {
      await file.delete();
    }
  }
}
