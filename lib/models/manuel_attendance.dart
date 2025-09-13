import 'package:soft_support_decktop/models/attendances.dart';

import 'res_partner.dart';

class ManuelAttendance {
  final ResPartner resPartner;
  final AttendanceRecord? attendanceRecord;

  ManuelAttendance({
    required this.resPartner,
    this.attendanceRecord,
  });

  // Méthode fromJson
  factory ManuelAttendance.fromJson(Map<String, dynamic> json) {
    return ManuelAttendance(
      resPartner: ResPartner.fromLocalFilterJson(json),
      attendanceRecord:
          json['id'] != null ? AttendanceRecord.fromLocalJson(json) : null,
    );
  }

  // Méthode toJson
  Map<String, dynamic> toJson() {
    final data = resPartner.toJson();
    if (attendanceRecord != null) {
      data.addAll(attendanceRecord!.toJson());
    }
    return data;
  }
}
