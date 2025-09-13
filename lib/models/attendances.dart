import 'package:soft_support_decktop/models/res_partner.dart';

class AttendanceRecord {
  final int id;
  final ResPartner partner;
  final DateTime checkIn;
  final bool isLocal;
  final int? makeAttendanceId;
  final String? latitude;
  final String? longitude;
  final DateTime? checkOut;
  final DateTime createDate;
  final DateTime updateDate;

  AttendanceRecord({
    this.makeAttendanceId,
    this.latitude,
    this.longitude,
    required this.id,
    required this.partner,
    required this.isLocal,
    required this.checkIn,
    this.checkOut,
    required this.createDate,
    required this.updateDate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      partner: ResPartner.fromJson(map['partner_id']),
      checkIn: DateTime.parse(map['check_in']),
      checkOut:
          map['check_out'] != null ? DateTime.tryParse(map['check_out']) : null,
      createDate: DateTime.parse(map['create_date']),
      updateDate: DateTime.parse(map['write_date']),
      isLocal: false,
      makeAttendanceId: map['make_attendance_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  factory AttendanceRecord.fromLocalJson(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      partner: ResPartner(
          id: map['id_user'],
          displayName: map['user_name'],
          rfidCode: map['rfidcode'],
          rfidNum: map['rfidcode_num'],
          personType: map['type'],
          avatar: map['image']),
      checkIn: DateTime.parse(map['checkin_time']),
      checkOut: map['checkout_time'] != null
          ? DateTime.tryParse(map['checkout_time'])
          : null,
      createDate: DateTime.parse(map['created_at']),
      updateDate: DateTime.parse(map['updated_at']),
      isLocal: map['isLocal'] == 0 ? false : true,
      makeAttendanceId: map['make_attendance_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  // Méthode pour convertir un AttendanceRecord en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_id': partner.toJson(),
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'create_date': createDate.toIso8601String(),
      'write_date': updateDate.toIso8601String(),
    };
  }
}

class AttendanceResponses {
  final bool success;
  final bool? isExist;
  final String message;

  AttendanceResponses({
    required this.message,
    required this.success,
    this.isExist,
  });

  // Désérialisation JSON
  factory AttendanceResponses.fromJson(Map<String, dynamic> json) {
    return AttendanceResponses(
      success: json['success'],
      message: json['message'],
      isExist: json['isExist'],
    );
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'isExist': isExist,
    };
  }
}

class MyPosition {
  final String latitude;
  final String longitude;

  MyPosition({required this.latitude, required this.longitude});

  factory MyPosition.fromJson(Map<String, dynamic> json) {
    return MyPosition(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
