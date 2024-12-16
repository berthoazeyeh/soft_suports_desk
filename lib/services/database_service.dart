import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('soft.educat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit(); // Ensure FFI is initialized
    databaseFactory = databaseFactoryFfi; // Use FFI for desktop
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create the table
    if (kDebugMode) {
      print("creation de la table");
    }
    await db.execute('''
      CREATE TABLE IF NOT EXISTS respartner (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                rfidcode TEXT ,
                rfidcode_num TEXT ,
                image TEXT,
                type TEXT
            );
    ''');
    if (kDebugMode) {
      print("creation de la table, ----respartner");
    }
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        email TEXT, 
        partner_id TEXT,
        phone TEXT,
        role TEXT,
        password TEXT
      ); ''');
    if (kDebugMode) {
      print("creation de la table, ----Users");
    }
    await db.execute('''
          CREATE TABLE IF NOT EXISTS attendance (
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
            FOREIGN KEY (id_user) REFERENCES respartner(id) ON DELETE CASCADE ON UPDATE CASCADE
        );''');
    if (kDebugMode) {
      print("creation de la table, ----attendance");
    }
    await db.execute('''
            CREATE TABLE IF NOT EXISTS attendance_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nom TEXT,
                datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                activity_name TEXT,
                rfid_code TEXT NOT NULL,
                status TEXT,
                message TEXT
            ); ''');
    if (kDebugMode) {
      print("creation de la table, ----attendance_log");
    }
  }
}
