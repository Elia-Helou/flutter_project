import 'base_model.dart';

class UserProgress extends BaseModel {
  final int userId;
  final DateTime date;
  final double weight; // in kg
  final double? targetWeight;
  final int caloriesConsumed;
  final int caloriesBurned;
  final int waterIntake; // in ml
  final int steps;
  final int sleepHours;
  final double? bmi;
  final Map<String, double> measurements; // body measurements
  final List<String> achievements;
  final String mood; // happy, sad, neutral, etc.
  final String? notes;

  UserProgress({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.date,
    required this.weight,
    this.targetWeight,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.waterIntake,
    required this.steps,
    required this.sleepHours,
    this.bmi,
    required this.measurements,
    required this.achievements,
    required this.mood,
    this.notes,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'target_weight': targetWeight,
      'calories_consumed': caloriesConsumed,
      'calories_burned': caloriesBurned,
      'water_intake': waterIntake,
      'steps': steps,
      'sleep_hours': sleepHours,
      'bmi': bmi,
      'measurements': measurements,
      'achievements': achievements,
      'mood': mood,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      targetWeight: json['target_weight']?.toDouble(),
      caloriesConsumed: json['calories_consumed'],
      caloriesBurned: json['calories_burned'],
      waterIntake: json['water_intake'],
      steps: json['steps'],
      sleepHours: json['sleep_hours'],
      bmi: json['bmi']?.toDouble(),
      measurements: Map<String, double>.from(json['measurements']),
      achievements: List<String>.from(json['achievements']),
      mood: json['mood'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 