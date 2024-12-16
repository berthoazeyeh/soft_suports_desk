import '../models/user.dart';
import 'database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import for ConflictAlgorithm

class StorageService {
  static final StorageService instance = StorageService._init();
  final DatabaseService _databaseService = DatabaseService.instance;

  StorageService._init();

  /// Fetch all user records from the `africasystem` table.
  Future<List<UserModel>> getAllRecords() async {
    final db = await _databaseService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'attendance',
        orderBy: 'id ASC', // Modify the ordering if necessary
      );
      return List.generate(maps.length, (i) => UserModel.fromJson(maps[i]));
    } catch (e) {
      print('Error fetching records: $e');
      return [];
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
      print('Error inserting record: $e');
    }
  }
}
