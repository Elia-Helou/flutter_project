import 'base_model.dart';

class FavoriteRecipe extends BaseModel {
  final int userId;
  final int recipeId;

  FavoriteRecipe({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.recipeId,
  });

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      id: json['id'],
      userId: json['user_id'],
      recipeId: json['recipe_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
