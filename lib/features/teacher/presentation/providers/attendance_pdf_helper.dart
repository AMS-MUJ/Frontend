import 'dart:io';
import 'package:ams_try2/features/teacher/domain/entities/attendance.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generateAttendancePdf(Attendance attendance) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Attendance Sheet',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Lecture ID: ${attendance.lectureId}'),
          pw.SizedBox(height: 20),

          pw.TableHelper.fromTextArray(
            headers: const ['Registration No', 'Status'],
            data: attendance.attendance
                .map((e) => [e.regNo, e.status])
                .toList(),
          ),
        ],
      ),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/${attendance.fileName}');
  await file.writeAsBytes(await pdf.save());

  return file;
}
