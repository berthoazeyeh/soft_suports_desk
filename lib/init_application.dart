import 'dart:developer';

import 'package:soft_support_decktop/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InitApplication {
  static Future<Database> initMyApplication() async {
    log('initialisation de la base de donnees');
    return await DatabaseService.instance.database;
  }
}
