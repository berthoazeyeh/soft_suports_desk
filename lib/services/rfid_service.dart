import 'package:flutter/foundation.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/models/res_partner.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/services/storage_service.dart';

import '../services/database_service.dart';

class RFIDService {
  final DatabaseService _databaseService = DatabaseService.instance;

  /// Ensure the table `attendance` exists and fetch user data by RFID code.
  Future<dynamic> getUserData(String rfidCode) async {
    try {
      final db = await _databaseService.database;
      if (kDebugMode) {
        print(rfidCode);
      }

      // Ensure the `attendance` table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nom TEXT,
                datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                activity_name TEXT,
                rfid_code TEXT NOT NULL,
                status TEXT,
                message TEXT
            );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance_students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user INTEGER NOT NULL,
            make_attendance_id INTEGER,
            is_checkin BOOLEAN DEFAULT 1,
            checkin_time DATETIME,
            checkout_time DATETIME,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            isLocal BOOLEAN DEFAULT 1,
            longitude TEXT,
            latitude TEXT,
            UNIQUE (id_user, checkin_time),
            FOREIGN KEY (id_user) REFERENCES respartner(id) ON DELETE CASCADE ON UPDATE CASCADE)
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS Users (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT, 
          email TEXT, 
          partner_id TEXT,
          phone TEXT,
          role TEXT,
          password TEXT
        );

      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          rfidcode TEXT ,
          image TEXT
        ); ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS respartner (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            rfidcode TEXT ,
            rfidcode_num TEXT ,
            image TEXT,
            type TEXT
        ); ''');

      // // Query user data by RFID code
      // final List<Map<String, dynamic>> result = await db.rawQuery(
      //   'SELECT * FROM respartner WHERE rfidcode = ? OR rfidcode_num= ? ;',
      //   [rfidCode, rfidCode],
      // );

      // if (result.isNotEmpty) {
      //   print("Il y a des données");

      //   // Convert the first matching result to a UserRecord object
      //   User userRecord = User.fromMap(result.first);

      //   // Call handleCreateAttendanceCorrect function
      //   final attendanceResult =
      //       await AttendanceService.instance.handleCreateAttendanceCorrect(
      //           userRecord.id, // Pass the user ID from the UserRecord
      //           db,
      //           userRecord.name, // Pass the user name from the UserRecord
      //           rfidCode,
      //           null, // This is acceptable if the parameter can accept null
      //           2,
      //           null, // This is acceptable if the parameter can accept null
      //           null,
      //           false // Pass the database instance
      //           );

      //   // Log the result of the attendance check
      //   print(attendanceResult['message']);

      //   return userRecord;
      // } else {
      //   print("Aucun utilisateur trouvé");
      //   return null;
      // }
    } catch (e) {
      throw Exception('Erreur base de données : $e');
    }
  }

  Future<List<String>> upsertAttendance(List<AttendanceRecord> dataList) async {
    try {
      final db = await _databaseService.database;
      List<String> results = [];

      await db.transaction((txn) async {
        for (var data in dataList) {
          final partner = data.partner;
          final int partnerId = partner.id;
          final String name = partner.displayName;
          final int recordId = data.id;
          final String checkinTime = data.checkIn.toIso8601String();
          final String? checkoutTime = data.checkOut?.toIso8601String();
          final bool isCheckin = checkoutTime == null;
          final String createdAt = data.updateDate.toIso8601String();

          // Vérifier si l'enregistrement existe déjà
          final List<Map<String, dynamic>> existingEntries = await txn.rawQuery(
            'SELECT * FROM attendance WHERE id = ?',
            [recordId],
          );

          if (existingEntries.isEmpty) {
            // Rechercher la dernière ligne locale si aucune entrée existante
            final List<Map<String, dynamic>> lastLocalEntries =
                await txn.rawQuery(
              '''
            SELECT * FROM attendance 
            WHERE id_user = ? AND isLocal = 1 
            ORDER BY created_at DESC 
            LIMIT 1
            ''',
              [partnerId],
            );

            if (lastLocalEntries.isEmpty) {
              // Insérer une nouvelle ligne
              await txn.rawInsert(
                '''
              INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) 
              VALUES (?, ?, ?, ?, ?, ?, ?)
              ''',
                [
                  recordId,
                  partnerId,
                  isCheckin ? 1 : 0,
                  checkinTime,
                  checkoutTime,
                  createdAt,
                  0
                ],
              );
              results.add(
                  'Nouvelle entrée insérée pour $name avec l\'ID $recordId');
            } else {
              // Comparer avec la dernière ligne locale
              final lastLocalEntry = lastLocalEntries.first;
              final bool hasChanged =
                  lastLocalEntry['checkin_time'] != checkinTime ||
                      lastLocalEntry['checkout_time'] != checkoutTime;

              if (hasChanged) {
                // Supprimer l'ancienne ligne locale et insérer la nouvelle
                await txn.rawDelete(
                  'DELETE FROM attendance WHERE id = ?',
                  [lastLocalEntry['id']],
                );
                await txn.rawInsert(
                  '''
                INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) 
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ''',
                  [
                    recordId,
                    partnerId,
                    isCheckin ? 1 : 0,
                    checkinTime,
                    checkoutTime,
                    createdAt,
                    0
                  ],
                );
                results.add(
                    'Ancienne entrée supprimée et nouvelle entrée insérée pour $name avec l\'ID $recordId');
              } else {
                results
                    .add('Aucune modification pour $name avec l\'ID $recordId');
              }
            }
          } else {
            // Entrée existante, vérifier si des modifications sont nécessaires
            final existingEntry = existingEntries.first;
            final bool hasChanged =
                existingEntry['checkin_time'] != checkinTime ||
                    existingEntry['checkout_time'] != checkoutTime;

            if (hasChanged && existingEntry['isLocal'] == 0) {
              // Mettre à jour l'entrée existante
              await txn.rawUpdate(
                '''
              UPDATE attendance 
              SET is_checkin = ?, checkin_time = ?, checkout_time = ?, isLocal = ? 
              WHERE id = ?
              ''',
                [isCheckin ? 1 : 0, checkinTime, checkoutTime, 0, recordId],
              );
              results.add('Entrée mise à jour pour $name avec l\'ID $recordId');
            } else {
              results
                  .add('Aucune modification pour $name avec l\'ID $recordId');
            }
          }
        }
      });
      if (kDebugMode) {
        print('Opération terminée pour tous les éléments de la liste');
      }
      return results;
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de l\'opération upsertAttendance : $error');
      }
      throw Exception('Erreur lors de l\'opération upsertAttendance');
    } finally {}
  }

  Future<List<String>> syncAllPartners(List<ResPartner> resPartner) async {
    final db = await _databaseService.database;

    try {
      return await db.transaction((txn) async {
        List<String> results = [];

        for (var request in resPartner) {
          if (kDebugMode) {
            print(request);
          }

          final List<Map<String, dynamic>> existing = await txn.rawQuery(
            'SELECT id FROM respartner WHERE id = ?',
            [request.id],
          );

          if (existing.isNotEmpty) {
            await txn.rawUpdate(
              '''
            UPDATE respartner
            SET 
              name = ?,
              rfidcode = ?,
              image = ?,
              type = ?,
              rfidcode_num = ?
            WHERE id = ?
            ''',
              [
                request.displayName,
                request.rfidCode,
                request.avatar,
                request.personType,
                request.rfidNum,
                request.id,
              ],
            );
            results.add('Updated: ${request.id}');
          } else {
            await txn.rawInsert(
              '''
            INSERT INTO respartner (
              id, name, rfidcode, image, type, rfidcode_num
            ) VALUES (?, ?, ?, ?, ?, ?)
            ''',
              [
                request.id,
                request.displayName,
                request.rfidCode,
                request.avatar,
                request.personType,
                request.rfidNum,
              ],
            );

            results.add('Inserted: ${request.id}');
          }
        }
        return results;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error during syncAllPartners: $error');
      }
      throw Exception('Failed to sync partners: $error');
    }
  }

  Future<List<ResPartner>> getAllLocalUserData() async {
    final db = await _databaseService.database;
    try {
      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> existing = await txn.rawQuery(
          'SELECT * FROM respartner ',
          [],
        );
        return existing.map((item) => ResPartner.fromLocalJson(item)).toList();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error during respartner: $error');
      }
      throw Exception('Failed to sync partners: $error');
    }
  }

  Future<CreateNewAttendanceType> handleCreateAttendanceCorrect({
    required int idUser,
    required String userName,
    required String rfidCode,
    int? makeAttendanceId,
    required int timing,
    MyPosition? coords,
    DateTime? checkTime,
  }) async {
    final db = await _databaseService.database;

    const model = 'attendance';

    final currentTime = DateTime.now();
    final currentHour = currentTime.hour;
    final String createdAt = currentTime.toIso8601String();
    final String updatedAt = currentTime.toIso8601String();
    final String? longitude = coords?.longitude;
    final String? latitude = coords?.latitude;
    final String greeting = (currentHour >= 5 && currentHour < 12)
        ? "Bonjour"
        : (currentHour >= 12 && currentHour < 15)
            ? "Bon après-midi"
            : "Bonsoir";

    try {
      // Start a transaction
      return await db.transaction((txn) async {
        // Check the last entry for the user
        final List<Map<String, dynamic>> rows = await txn.rawQuery(
          'SELECT * FROM $model WHERE id_user = ? ORDER BY updated_at DESC LIMIT 1;',
          [idUser],
        );

        String finalMessage = '';
        bool isCheckin;
        String? checkinTime;
        String? checkoutTime;

        if (rows.isEmpty) {
          // No existing entry, perform check-in
          isCheckin = true;
          checkinTime = checkTime?.toIso8601String() ?? createdAt;

          finalMessage =
              "$greeting $userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat('HH:mm').format(currentTime)}";

          // Insert new check-in
          await txn.rawInsert(
            'INSERT INTO $model (id_user, is_checkin, checkin_time, checkout_time, created_at, updated_at, make_attendance_id, longitude, latitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
            [
              idUser,
              isCheckin == true ? 1 : 0,
              checkinTime,
              checkoutTime,
              createdAt,
              updatedAt,
              makeAttendanceId,
              longitude,
              latitude,
            ],
          );

          // Log the activity
          await txn.rawInsert(
            'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
            [
              userName,
              createdAt,
              'check_in',
              rfidCode,
              'success',
              finalMessage
            ],
          );

          return (data: isCheckin, success: true, message: finalMessage);
        } else {
          final lastEntry = rows.first;
          final DateTime lastCheckTime = DateTime.parse(
            lastEntry['checkout_time'] ?? lastEntry['checkin_time'],
          );
          final DateTime currentCheckTime = checkTime ?? DateTime.now();
          final timeDifferenceMinutes =
              currentCheckTime.difference(lastCheckTime).inMinutes;

          if (timeDifferenceMinutes <= timing) {
            finalMessage =
                "$userName, vous avez badgé il y a $timeDifferenceMinutes minutes. Vous pouvez encore badger dans ${timing - timeDifferenceMinutes} minutes.";

            await txn.rawInsert(
              'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
              [
                userName,
                createdAt,
                'unknown',
                rfidCode,
                'failed',
                finalMessage
              ],
            );

            return (data: {}, success: false, message: finalMessage);
          } else if (lastEntry['checkin_time'] != null &&
              lastEntry['checkout_time'] == null) {
            // Last entry is a check-in without a check-out, perform check-out
            isCheckin = false;
            checkoutTime = checkTime?.toIso8601String() ?? createdAt;

            finalMessage =
                "$greeting $userName, Au revoir! Vous venez de quitter à : ${DateFormat('HH:mm').format(currentTime)}";

            // Update the last entry
            await txn.rawUpdate(
              'UPDATE $model SET checkout_time = ?, isLocal = ?, updated_at = ?, make_attendance_id = ?, longitude = ?, latitude = ? WHERE id = ?;',
              [
                checkoutTime,
                1,
                updatedAt,
                makeAttendanceId,
                longitude,
                latitude,
                lastEntry['id'],
              ],
            );

            // Log the activity
            await txn.rawInsert(
              'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
              [
                userName,
                createdAt,
                'check_out',
                rfidCode,
                'success',
                finalMessage
              ],
            );

            return (data: isCheckin, success: true, message: finalMessage);
          } else {
            // Perform new check-in
            isCheckin = true;
            checkinTime = checkTime?.toIso8601String() ?? createdAt;

            finalMessage =
                "$greeting $userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat('HH:mm').format(currentTime)}";

            await txn.rawInsert(
              'INSERT INTO $model (id_user, is_checkin, checkin_time, checkout_time, created_at, updated_at, make_attendance_id, longitude, latitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
              [
                idUser,
                isCheckin == true ? 1 : 0,
                checkinTime,
                checkoutTime,
                createdAt,
                updatedAt,
                makeAttendanceId,
                longitude,
                latitude,
              ],
            );

            // Log the activity
            await txn.rawInsert(
              'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
              [
                userName,
                createdAt,
                'check_in',
                rfidCode,
                'success',
                finalMessage
              ],
            );

            return (data: isCheckin, success: true, message: finalMessage);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erreur: $e");
      }
      return (data: null, success: false, message: 'Erreur inattendue');
    }
  }

  Future<GetUserByRfidCodeType> getUserByRfidCode(
      String rfidCode, double timing) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM respartner WHERE rfidcode = ? OR rfidcode_num = ?;',
        [rfidCode, rfidCode],
      );

      if (result.isNotEmpty) {
        final user = result.first; // Récupère le premier utilisateur trouvé
        final resPartner = ResPartner.fromLocalJson(user);
        final handleCreateRes = await handleCreateAttendanceCorrect(
          idUser: resPartner.id,
          userName: resPartner.displayName,
          rfidCode: rfidCode,
          makeAttendanceId: null,
          timing: timing.toInt(), // Temps de badgé en minutes
        );
        return (
          success: handleCreateRes.success,
          data: resPartner,
          message: handleCreateRes.message,
        );
      } else {
        return (
          success: false,
          data: null,
          message:
              "Nous avons du mal à vous reconnaître, veuillez réessayer s'il vous plaît.",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'utilisateur: $e');
      }
      return (
        success: false,
        data: null,
        message: "Erreur lors de la récupération de l'utilisateur",
      );
    }
  }

  Future<Map<String, dynamic>> updateAttendanceLocal(int id) async {
    final db = await _databaseService.database;

    try {
      await db.transaction((txn) async {
        await txn.rawUpdate(
          "UPDATE attendance SET isLocal = ? WHERE id = ?;",
          [0, id],
        );
      });
      return {'data': 'types', 'success': true}; // Retour en cas de succès
    } catch (error) {
      return {
        'error': error.toString(),
        'success': false
      }; // Retour en cas d'échec
    }
  }

  Future<GetResponse$Attendance> getUnSyncAttendance() async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
        SELECT attendance.*,
               respartner.name AS user_name,
               respartner.id AS user_id,
               respartner.type,
               respartner.rfidcode,
               respartner.rfidcode_num,
               respartner.image
        FROM attendance
        LEFT JOIN respartner ON attendance.id_user = respartner.id
         WHERE attendance.isLocal = 1 ORDER BY attendance.updated_at DESC
        ''',
        [],
      );

      // Préparez les données en format souhaité
      final List<Map<String, dynamic>> requests =
          results.map((row) => row).toList();
      final List<AttendanceRecord> attendances =
          requests.map((map) => AttendanceRecord.fromLocalJson(map)).toList();
      return (data: attendances, success: true, message: '');
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching unsynced attendance: $error");
      }
      return (
        success: false,
        message: error.toString(),
        data: [] as List<AttendanceRecord>
      );
    }
  }
}

typedef GetUserByRfidCodeType = ({
  ResPartner? data,
  bool success,
  String message,
});
typedef CreateNewAttendanceType = ({
  dynamic data,
  bool success,
  String message,
});
