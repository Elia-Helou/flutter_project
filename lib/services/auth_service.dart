import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

// final String baseUrl = 'http://10.0.2.2:5000';
final String baseUrl = 'http://127.0.0.1:5000';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        // Load the user from prefs
        User user = User.fromMap(userMap);
        // Fetch the latest user data from the database using the email
        final userData = await _dbHelper.getUserByEmail(user.email);
        if (userData != null) {
          user = User.fromMap(userData);
          // Save the fresh user data to prefs
          await _saveUserToPrefs(user);
        }
        _currentUser = user;
      }
    } catch (e) {
      debugPrint('Error loading user from prefs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString('user', jsonEncode(user.toJson()));
      } else {
        await prefs.remove('user');
      }
    } catch (e) {
      debugPrint('Error saving user to prefs: $e');
    }
  }

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

      final user = User.fromMap(userData);
      _currentUser = user;
      await _saveUserToPrefs(user);
      notifyListeners();
      return user;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
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
    required String phone_number,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      await _dbHelper.updateUserProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone_number: phone_number,
        gender: gender,
        dateOfBirth: dateOfBirth,
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

  Future<void> updateEmail(String currentEmail, String newEmail) async {
    try {
      await _dbHelper.updateUserEmail(currentEmail, newEmail);
      notifyListeners();
    } catch (e) {
      debugPrint('Update email error: $e');
      rethrow;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw Exception('User not found');
      }

      final dbPassword = userData['password'];
      if (dbPassword == null) {
        throw Exception('Password in database is null');
      }

      return BCrypt.checkpw(password, dbPassword);
    } catch (e) {
      debugPrint('Verify password error: $e');
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      // First check if email exists in database
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw 'Email not found';
      }

      // Request reset code from server
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'email_exists': true,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'];
        throw error ?? 'Failed to send reset code';
      }

      // Store reset code in database
      final resetCode = jsonDecode(response.body)['code'];
      await _dbHelper.updateUserResetCode(email, resetCode);
    } catch (e) {
      throw 'Failed to send reset code: $e';
    }
  }

  Future<void> verifyResetCode(String email, String code) async {
    try {
      // Verify code in database
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null || userData['reset_code'] != code) {
        throw 'Invalid code';
      }
    } catch (e) {
      throw 'Failed to verify code: $e';
    }
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      // Verify code in database
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null || userData['reset_code'] != code) {
        throw 'Invalid code';
      }

      // Hash the new password
      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      // Update password and clear reset code
      await _dbHelper.updateUserPassword(email, hashedPassword);
      await _dbHelper.updateUserResetCode(email, null);
    } catch (e) {
      throw 'Failed to reset password: $e';
    }
  }
} 