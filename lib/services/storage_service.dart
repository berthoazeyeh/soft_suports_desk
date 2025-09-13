import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/models/manuel_attendance.dart';
import 'package:soft_support_decktop/models/res_partner.dart';

import '../models/user.dart';
import 'database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import for ConflictAlgorithm

typedef GetResponse$Attendance = ({
  bool success,
  List<AttendanceRecord> data,
  String message,
});
typedef GetResponse$FilterAttendance = ({
  bool success,
  List<ManuelAttendance> data,
  String message,
});

class StorageService {
  static final StorageService instance = StorageService._init();
  final DatabaseService _databaseService = DatabaseService.instance;

  StorageService._init();

  /// Fetch all user records from the `africasystem` table.
  Future<List<ResPartner>> getAllRecords() async {
    final db = await _databaseService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'attendance',
        orderBy: 'id ASC', // Modify the ordering if necessary
      );
      return List.generate(maps.length, (i) => ResPartner.fromJson(maps[i]));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching records: $e');
      }
      return [];
    }
  }

// Fonction pour récupérer les présences
  Future<GetResponse$Attendance> getAllAttendances(
      {required bool isStudent, String? date}) async {
    final type = isStudent ? 'student' : 'faculty';
    final db = await _databaseService.database;

    final String query = date != null
        ? '''
        SELECT attendance.*,
               respartner.name AS user_name,
               respartner.id AS user_id,
               respartner.type,
               respartner.rfidcode,
               respartner.rfidcode_num,
               respartner.image
        FROM attendance
        LEFT JOIN respartner ON attendance.id_user = respartner.id
        WHERE respartner.type = ? AND (DATE(attendance.checkin_time) = ? OR DATE(attendance.checkout_time)= ?)
        ORDER BY attendance.created_at DESC;
      '''
        : '''
        SELECT attendance.*,
               respartner.name AS user_name,
               respartner.id AS user_id,
               respartner.type,
                respartner.rfidcode,
               respartner.rfidcode_num,
               respartner.image
        FROM attendance
        LEFT JOIN respartner ON attendance.id_user = respartner.id
        WHERE respartner.type = ?
        ORDER BY attendance.created_at DESC;
      ''';

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        date != null ? [type, date, date] : [type],
      );
      final List<AttendanceRecord> attendances =
          results.map((map) => AttendanceRecord.fromLocalJson(map)).toList();

      return (data: attendances, success: true, message: '');
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching attendances: $error');
      }
      return (data: [] as List<AttendanceRecord>, success: false, message: '');
    }
  }

  Future<GetResponse$FilterAttendance> getFilterAttendances(
      bool isStudent) async {
    try {
      final db = await _databaseService.database;

      final String type = isStudent ? 'student' : 'faculty';
      const String model = 'attendance';

      final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT a.*,
             af.name AS user_name,
             af.rfidcode,
             af.id AS user_id,
             af.type,
              af.rfidcode,
               af.rfidcode_num,
               af.image
      FROM respartner af
      LEFT JOIN $model a 
      ON a.id_user = af.id AND a.updated_at = (
        SELECT MAX(updated_at) 
        FROM $model 
        WHERE id_user = af.id
      )
      WHERE af.type = ?
      ORDER BY af.name ASC;
    ''', [type]);

      // Transformation des résultats en liste d'objets
      List<Map<String, dynamic>> requests = results.map((row) => row).toList();
      log('/////////');

      final List<ManuelAttendance> attendances =
          requests.map((map) => ManuelAttendance.fromJson(map)).toList();

      return (data: attendances, success: true, message: '');
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des présences filtrées : $error');
      }
      return (
        data: [] as List<ManuelAttendance>,
        success: false,
        message: '$error'
      );
    }
  }

  /// Insert a new user record into the `africasystem` table.
  Future<void> insertRecord(UserModel record) async {
    final db = await _databaseService.database;

    try {
      await db.insert(
        'africasystem',
        record.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting record: $e');
      }
    }
  }
}
