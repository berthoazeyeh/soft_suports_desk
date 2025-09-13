import 'package:soft_support_decktop/models/attendances.dart';

class AttendanceUiData {
  final bool success;
  final List<AttendanceRecord> attendances;

  AttendanceUiData({required this.success, required this.attendances});

  factory AttendanceUiData.fromJson(Map<String, dynamic> json) {
    return AttendanceUiData(
      success: json['success'],
      attendances: ((json['data']) as List? ?? [])
          .map((item) => AttendanceRecord.fromJson(item))
          .toList(),
    );
  }

  // Méthode pour convertir l'objet ResPartner en une carte (map)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'attendances': attendances,
    };
  }
}
