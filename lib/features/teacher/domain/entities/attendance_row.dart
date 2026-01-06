class AttendanceRow {
  final String regNo;
  final String status;

  AttendanceRow({required this.regNo, required this.status});

  factory AttendanceRow.fromJson(Map<String, dynamic> json) {
    return AttendanceRow(regNo: json['regNo'], status: json['status']);
  }
}
