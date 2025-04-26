import 'base_model.dart';

class User extends BaseModel {
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String activityLevel; // sedentary, light, moderate, very active, extra active
  final String dietaryPreferences; // vegetarian, vegan, etc.
  final List<String> allergies;
  final String? profileImageUrl;
  final double? targetWeight;
  final String? goal; // weight loss, maintenance, muscle gain

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
    required this.dietaryPreferences,
    required this.allergies,
    this.profileImageUrl,
    this.targetWeight,
    this.goal,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'activity_level': activityLevel,
      'dietary_preferences': dietaryPreferences,
      'allergies': allergies,
      'profile_image_url': profileImageUrl,
      'target_weight': targetWeight,
      'goal': goal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      passwordHash: json['password_hash'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      activityLevel: json['activity_level'],
      dietaryPreferences: json['dietary_preferences'],
      allergies: List<String>.from(json['allergies']),
      profileImageUrl: json['profile_image_url'],
      targetWeight: json['target_weight']?.toDouble(),
      goal: json['goal'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 