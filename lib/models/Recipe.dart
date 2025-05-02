import 'base_model.dart';
import 'Food.dart';

class Recipe extends BaseModel {
  final String name;
  final String? description;
  final String instructions;
  final String? imageUrl;
  final int preparationTime;
  final int servings;
  final List<String> categories;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbohydrates;
  final double totalFats;
  final double rating;

  Recipe({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.description,
    required this.instructions,
    this.imageUrl,
    required this.preparationTime,
    required this.servings,
    required this.categories,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbohydrates,
    required this.totalFats,
    required this.rating,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      preparationTime: json['preparation_time'],
      servings: json['servings'],
      categories: List<String>.from(json['categories']),
      totalCalories: json['total_calories'],
      totalProtein: json['total_protein'],
      totalCarbohydrates: json['total_carbohydrates'],
      totalFats: json['total_fats'],
      rating: json['rating'] ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'preparation_time': preparationTime,
      'servings': servings,
      'categories': categories,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbohydrates': totalCarbohydrates,
      'total_fats': totalFats,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}