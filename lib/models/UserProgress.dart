import 'package:intl/intl.dart';

import 'base_model.dart';

class UserProgress extends BaseModel {
  final int userId;
  final double weight;
  final double height;
  final double bmiValue;
  final DateTime? loggedAt;

  UserProgress({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.weight,
    required this.height,
    required this.bmiValue,
    this.loggedAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      userId: json['user_id'],
      weight: json['weight'],
      height: json['height'],
      bmiValue: json['bmivalue'],
      loggedAt: json['logged_at'] != null ? DateTime.parse(json['logged_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'height': height,
      'bmivalue': bmiValue,
      'logged_at': loggedAt != null ? DateFormat('yyyy-MM-dd').format(loggedAt!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}