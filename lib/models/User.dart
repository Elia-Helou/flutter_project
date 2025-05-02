import 'package:intl/intl.dart';

import 'base_model.dart';

class User extends BaseModel {
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final double height;
  final double weight;
  final String? activityLevel;
  final String? profileImageUrl;
  final double? targetWeight;

  User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.profileImageUrl,
    this.targetWeight,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      passwordHash: json['password_hash'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      activityLevel: json['activity_level'],
      profileImageUrl: json['profile_image_url'],
      targetWeight: json['target_weight'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
      'gender': gender,
      'height': height,
      'weight': weight,
      'activity_level': activityLevel,
      'profile_image_url': profileImageUrl,
      'target_weight': targetWeight,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
