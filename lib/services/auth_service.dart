import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<User?> login(String email, String password) async {
    try {
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw Exception('User not found');
      }

      final dbPassword = userData['password'];
      if (dbPassword == null) {
        throw Exception('Password in database is null');
      }

      final isPasswordCorrect = BCrypt.checkpw(password, dbPassword);
      if (!isPasswordCorrect) {
        throw Exception('Invalid password');
      }

      return User.fromMap(userData);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
    required String phoneNumber,
    String? activityLevel,
    double? targetWeight,
  }) async {
    try {
      // Hash the password
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Create user in database
      await _dbHelper.createUser(
        email: email,
        password: hashedPassword,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dateOfBirth: dateOfBirth.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        height: height.toString(),
        weight: weight.toString(),
        phoneNumber: phoneNumber,
        activityLevel: activityLevel,
        targetWeight: targetWeight?.toString(),
      );

      // Fetch the created user
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw Exception('Failed to fetch created user');
      }

      return User.fromMap(userData);
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phone_number
  }) async {
    try {
      await _dbHelper.updateUserProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone_number: phone_number
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    try {
      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await _dbHelper.updateUserPassword(email, hashedPassword);
    } catch (e) {
      debugPrint('Update password error: $e');
      rethrow;
    }
  }
} 