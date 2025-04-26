import 'base_model.dart';

class Goal extends BaseModel {
  final int userId;
  final String title;
  final String description;
  final String type; // weight, steps, calories, water, etc.
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;
  final String? reward;
  final int? streak; // consecutive days of achieving the goal
  final List<String> milestones;
  final String? notes;

  Goal({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.targetDate,
    this.isCompleted = false,
    this.reward,
    this.streak = 0,
    required this.milestones,
    this.notes,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type,
      'target_value': targetValue,
      'current_value': currentValue,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'is_completed': isCompleted,
      'reward': reward,
      'streak': streak,
      'milestones': milestones,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      targetValue: json['target_value'].toDouble(),
      currentValue: json['current_value'].toDouble(),
      startDate: DateTime.parse(json['start_date']),
      targetDate: DateTime.parse(json['target_date']),
      isCompleted: json['is_completed'] ?? false,
      reward: json['reward'],
      streak: json['streak'],
      milestones: List<String>.from(json['milestones']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 