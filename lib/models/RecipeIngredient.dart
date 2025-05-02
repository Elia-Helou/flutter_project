import 'base_model.dart';

class RecipeIngredient extends BaseModel {
  final int recipeId;
  final int foodId;
  final double amount;
  final String unit;

  RecipeIngredient({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.recipeId,
    required this.foodId,
    required this.amount,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      recipeId: json['recipe_id'],
      foodId: json['food_id'],
      amount: json['amount'],
      unit: json['unit'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'food_id': foodId,
      'amount': amount,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}