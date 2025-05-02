import 'package:intl/intl.dart';

import 'base_model.dart';

class User extends BaseModel {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String height;
  final String weight;
  final String goalWeight;
  final String activityLevel;
  final String goal;

  User({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    required this.goalWeight,
    required this.activityLevel,
    required this.goal,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      password: map['password'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      phoneNumber: map['phone_number'] as String,
      gender: map['gender'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      height: map['height'] as String,
      weight: map['weight'] as String,
      goalWeight: map['goal_weight'] as String,
      activityLevel: map['activity_level'] as String,
      goal: map['goal'] as String,
      createdAt: map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] is DateTime ? map['updated_at'] : DateTime.parse(map['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
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
    String? height,
    String? weight,
    String? goalWeight,
    String? activityLevel,
    String? goal,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
