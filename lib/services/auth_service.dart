import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

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

      if (dbPassword.toString().trim() != password.trim()) {
        throw Exception('Invalid password');
      }

      return User.fromMap(userData);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }


  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required String goalWeight,
    required String activityLevel,
    required String goal,
  }) async {
    try {
      await _dbHelper.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        goalWeight: goalWeight,
        activityLevel: activityLevel,
        goal: goal,
      );

      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw Exception('Failed to create user');
      }

      return User.fromMap(userData);
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required String goalWeight,
    required String activityLevel,
    required String goal,
  }) async {
    try {
      return await _dbHelper.updateUserProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        goalWeight: goalWeight,
        activityLevel: activityLevel,
        goal: goal,
      );
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<bool> changePassword(String email, String newPassword) async {
    try {
      return await _dbHelper.updateUserPassword(email, newPassword);
    } catch (e) {
      debugPrint('Change password error: $e');
      rethrow;
    }
  }
} 