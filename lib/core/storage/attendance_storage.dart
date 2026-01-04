import 'dart:convert';
import 'package:ams_try2/features/teacher/domain/entities/attendance_files.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _key = 'attendance_files';

final _storage = FlutterSecureStorage();

Future<void> saveAttendanceFile(AttendanceFile file) async {
  final existing = await getAttendanceFiles();
  final updated = [...existing, file];

  await _storage.write(
    key: _key,
    value: jsonEncode(updated.map((e) => e.toJson()).toList()),
  );
}

Future<List<AttendanceFile>> getAttendanceFiles() async {
  final raw = await _storage.read(key: _key);
  if (raw == null) return [];

  final list = jsonDecode(raw) as List;
  return list.map((e) => AttendanceFile.fromJson(e)).toList();
}
