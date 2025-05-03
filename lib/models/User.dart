import 'package:intl/intl.dart';

import 'base_model.dart';

class User extends BaseModel {
  final String email;
  final String password; // Matches the database field
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final double height; // Changed to double for DECIMAL(5,2) in DB
  final double weight; // Changed to double for DECIMAL(5,2) in DB
  final double? goalWeight; // Changed to double for DECIMAL(5,2) in DB
  final String activityLevel;
  final String? goal;
  final String? profileImageUrl; // Nullable field for profile_image_url

  User({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.email,
    required this.password, // Matches the database field
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    this.goalWeight,
    required this.activityLevel,
    this.goal,
    this.profileImageUrl, // Nullable field
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      password: map['password'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      phoneNumber: map['phone_number'] as String? ?? '', // Handle null for phoneNumber
      gender: map['gender'] as String,
      dateOfBirth: map['date_of_birth'] is String
          ? DateTime.parse(map['date_of_birth'] as String).toIso8601String()
          : (map['date_of_birth'] as DateTime).toIso8601String(),
      // Convert height and weight to num (double)
      height: (map['height'] is String ? double.tryParse(map['height'] as String) : map['height']) ?? 0.0,
      weight: (map['weight'] is String ? double.tryParse(map['weight'] as String) : map['weight']) ?? 0.0,
      goalWeight: map['target_weight'] != null
          ? (map['target_weight'] is String ? double.tryParse(map['target_weight'] as String) : map['target_weight'])
          : null,
      activityLevel: map['activity_level'] as String? ?? '',
      goal: map['goal'] as String?,
      profileImageUrl: map['profile_image_url'] as String? ?? '',
      createdAt: map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] is DateTime ? map['updated_at'] : DateTime.parse(map['updated_at']),
    );
  }


  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password, // Matches the database field
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'height': height,
      'weight': weight,
      'goal_weight': goalWeight,
      'activity_level': activityLevel,
      'goal': goal,
      'profile_image_url': profileImageUrl, // Nullable field
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    double? height, // Changed to double for DECIMAL
    double? weight, // Changed to double for DECIMAL
    double? goalWeight, // Changed to double for DECIMAL
    String? activityLevel,
    String? goal,
    String? profileImageUrl, // Nullable field
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goalWeight: goalWeight ?? this.goalWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
