import 'dart:io';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generateAttendancePdf(Attendance attendance) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text(
          'Attendance Sheet',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),

        pw.Text('Lecture ID: ${attendance.lectureId}'),
        pw.Text('Date: ${DateTime.now()}'),
        pw.SizedBox(height: 20),

        pw.TableHelper.fromTextArray(
          headers: const ['Registration No', 'Status'],
          data: attendance.attendance.map((e) => [e.regNo, e.status]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/Attendance_${attendance.lectureId}.pdf');

  await file.writeAsBytes(await pdf.save());
  return file;
}
