import 'base_model.dart';
import 'food.dart';

class FoodLog extends BaseModel {
  final int userId;
  final int foodId;
  final DateTime dateTime;
  final double servingSize;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? notes;
  final bool isFavorite;
  final String? imageUrl; // for AI recognition results

  FoodLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.foodId,
    required this.dateTime,
    required this.servingSize,
    required this.mealType,
    this.notes,
    this.isFavorite = false,
    this.imageUrl,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_id': foodId,
      'date_time': dateTime.toIso8601String(),
      'serving_size': servingSize,
      'meal_type': mealType,
      'notes': notes,
      'is_favorite': isFavorite,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'],
      userId: json['user_id'],
      foodId: json['food_id'],
      dateTime: DateTime.parse(json['date_time']),
      servingSize: json['serving_size'].toDouble(),
      mealType: json['meal_type'],
      notes: json['notes'],
      isFavorite: json['is_favorite'] ?? false,
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 