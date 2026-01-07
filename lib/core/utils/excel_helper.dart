// import 'dart:io';
// import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
//
// Future<File> generateAttendanceExcel(Attendance attendance) async {
//   final excel = Excel.createExcel();
//   final sheet = excel['Attendance'];
//
//   sheet.appendRow(['Registration No', 'Status']);
//
//   for (final row in attendance.attendance) {
//     sheet.appendRow([row.regNo, row.status]);
//   }
//
//   final dir = await getApplicationDocumentsDirectory();
//   final file = File('${dir.path}/${attendance.fileName}');
//   file.writeAsBytesSync(excel.encode()!);
//
//   return file;
// }
