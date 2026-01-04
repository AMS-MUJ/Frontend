import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final attendanceFilesProvider = FutureProvider<List<File>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.xlsx'))
      .toList();

  return files;
});
