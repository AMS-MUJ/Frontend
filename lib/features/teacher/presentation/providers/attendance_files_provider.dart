import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final attendanceFilesProvider = FutureProvider<List<File>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.pdf'))
      .toList();

  files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  return files;
});

class AttendanceFileUtils {
  static Future<void> clearAll(WidgetRef ref) async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.pdf'),
    );

    for (final file in files) {
      await file.delete();
    }

    ref.invalidate(attendanceFilesProvider);
  }
}
