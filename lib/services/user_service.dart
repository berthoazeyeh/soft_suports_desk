import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soft_support_decktop/api/api_client.dart';
import 'package:soft_support_decktop/api/ui_models/time_ui_data.dart';

import '../services/database_service.dart';

class UserService {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<LoginResponse> onLineLogin(
      {required String email,
      required String password,
      required String database}) async {
    try {
      final res = await APIClient().login(email, password, database);
      return res;
    } catch (e) {
      EasyLoading.showError('Failed with Error $e');
      throw ('Une erreur s\'est produite lors du login');
    }
  }

  Future<Map<String, dynamic>> loginUserWithPartner(
      String email, String password) async {
    try {
      final db = await _databaseService.database;

      // Requête SQL pour vérifier les informations de connexion
      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
      SELECT * FROM Users 
      WHERE email = ? AND password = ?
      ''',
        [email, password],
      );

      if (results.isNotEmpty) {
        // Utilisateur trouvé
        return {
          'success': true,
          'data': results.first, // Toutes les données utilisateur
        };
      } else {
        // Utilisateur non trouvé
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }
    } catch (error) {
      // En cas d'erreur lors de la requête
      return {
        'success': false,
        'message': 'Erreur lors de la connexion: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createUserWithPartner({
    required int id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required int partnerId,
  }) async {
    try {
      final db = await _databaseService.database;
      // Vérifier si l'email existe déjà
      final List<Map<String, dynamic>> existingUsers = await db.rawQuery(
        'SELECT * FROM Users WHERE email = ?',
        [email],
      );

      if (existingUsers.isNotEmpty) {
        // Email déjà utilisé
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé.',
        };
      }

      // Insérer un nouvel utilisateur
      final int userId = await db.rawInsert(
        '''
      INSERT INTO Users (id, name, email, password, partner_id, phone, role) 
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        [id, name, email, password, partnerId, phone, role],
      );

      return {
        'success': true,
        'message': 'Utilisateur créé avec succès.',
        'data': {
          'id': id,
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          'partner_id': partnerId,
          'user_id': userId,
        },
      };
    } catch (error) {
      // En cas d'erreur lors de l'insertion
      return {
        'success': false,
        'message':
            'Erreur lors de la création de l’utilisateur: ${error.toString()}',
      };
    }
  }
}
