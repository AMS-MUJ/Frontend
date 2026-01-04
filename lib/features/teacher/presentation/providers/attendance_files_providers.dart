import 'package:ams_try2/core/storage/attendance_storage.dart';
import 'package:ams_try2/features/teacher/domain/entities/attendance_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceFilesProvider = FutureProvider<List<AttendanceFile>>((
  ref,
) async {
  return getAttendanceFiles();
});
