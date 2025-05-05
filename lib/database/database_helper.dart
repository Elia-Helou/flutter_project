import 'package:postgres/postgres.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Connection> get connection async {
    return await DatabaseService.instance.connection;
  }

  Future<bool> checkConnection() async {
    try {
      final conn = await connection;
      final result = await conn.execute('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      return false;
    }
  }

  Future<bool> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required String phoneNumber,
    String? activityLevel,
    String? targetWeight,
  }) async {
    try {
      final conn = await connection;
      
      // Check if user already exists
      final checkResult = await conn.execute(
        Sql.named('SELECT COUNT(*) FROM users WHERE email = @email'),
        parameters: {'email': email},
      );

      if (checkResult.isNotEmpty && (checkResult.first[0] as int) > 0) {
        throw Exception('User with this email already exists');
      }

      // Insert new user
      await conn.execute(
        Sql.named('''
        INSERT INTO users (
          email, password, first_name, last_name,
          gender, date_of_birth, height, weight,
          phone_number,
          activity_level, target_weight
        ) VALUES (
          @email, @password, @firstName, @lastName,
          @gender, @dateOfBirth, @height, @weight,
          @phoneNumber,
          @activityLevel, @targetWeight
        )
        '''),
        parameters: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'height': height,
          'weight': weight,
          'phoneNumber': phoneNumber,
          'activityLevel': activityLevel,
          'targetWeight': targetWeight,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final conn = await connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM users WHERE email = @email'),
        parameters: {'email': email},
      );

      if (result.isEmpty) {
        return null;
      }

      final row = result.first.toColumnMap();
      debugPrint('DB row: $row');
      return row;
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  Future<bool> updateUserProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phone_number,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final conn = await connection;
      
      await conn.execute(
        Sql.named('''
        UPDATE users SET
          first_name = @firstName,
          last_name = @lastName,
          phone_number = @phone_number,
          gender = @gender,
          date_of_birth = @dateOfBirth,
          updated_at = CURRENT_TIMESTAMP
        WHERE email = @email
        '''),
        parameters: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'phone_number': phone_number,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    try {
      final conn = await connection;
      
      await conn.execute(
        Sql.named('UPDATE users SET password = @password, updated_at = CURRENT_TIMESTAMP WHERE email = @email'),
        parameters: {
          'email': email,
          'password': newPassword,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  Future<bool> updateUserEmail(String currentEmail, String newEmail) async {
    try {
      final conn = await connection;
      
      // Check if new email already exists
      final checkResult = await conn.execute(
        Sql.named('SELECT COUNT(*) FROM users WHERE email = @email'),
        parameters: {'email': newEmail},
      );

      if (checkResult.isNotEmpty && (checkResult.first[0] as int) > 0) {
        throw Exception('Email already in use');
      }

      await conn.execute(
        Sql.named('UPDATE users SET email = @newEmail, updated_at = CURRENT_TIMESTAMP WHERE email = @currentEmail'),
        parameters: {
          'currentEmail': currentEmail,
          'newEmail': newEmail,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }
} 