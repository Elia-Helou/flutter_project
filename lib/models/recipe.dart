import 'base_model.dart';
import 'food.dart';

class Recipe extends BaseModel {
  final String name;
  final String description;
  final String instructions;
  final String? imageUrl;
  final int preparationTime; // in minutes
  final int cookingTime; // in minutes
  final int servings;
  final String difficulty; // easy, medium, hard
  final List<String> categories; // breakfast, lunch, dinner, snack, etc.
  final List<String> tags; // vegetarian, vegan, gluten-free, etc.
  final List<RecipeIngredient> ingredients;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbohydrates;
  final double totalFats;
  final String createdBy; // user ID
  final bool isPublic;
  final double rating;
  final int numberOfRatings;

  Recipe({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.description,
    required this.instructions,
    this.imageUrl,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.categories,
    required this.tags,
    required this.ingredients,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbohydrates,
    required this.totalFats,
    required this.createdBy,
    this.isPublic = true,
    this.rating = 0.0,
    this.numberOfRatings = 0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'preparation_time': preparationTime,
      'cooking_time': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'categories': categories,
      'tags': tags,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbohydrates': totalCarbohydrates,
      'total_fats': totalFats,
      'created_by': createdBy,
      'is_public': isPublic,
      'rating': rating,
      'number_of_ratings': numberOfRatings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      preparationTime: json['preparation_time'],
      cookingTime: json['cooking_time'],
      servings: json['servings'],
      difficulty: json['difficulty'],
      categories: List<String>.from(json['categories']),
      tags: List<String>.from(json['tags']),
      ingredients: (json['ingredients'] as List)
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      totalCalories: json['total_calories'].toDouble(),
      totalProtein: json['total_protein'].toDouble(),
      totalCarbohydrates: json['total_carbohydrates'].toDouble(),
      totalFats: json['total_fats'].toDouble(),
      createdBy: json['created_by'],
      isPublic: json['is_public'] ?? true,
      rating: json['rating']?.toDouble() ?? 0.0,
      numberOfRatings: json['number_of_ratings'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class RecipeIngredient {
  final int foodId;
  final double amount;
  final String unit;
  final String? notes;

  RecipeIngredient({
    required this.foodId,
    required this.amount,
    required this.unit,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'amount': amount,
      'unit': unit,
      'notes': notes,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      foodId: json['food_id'],
      amount: json['amount'].toDouble(),
      unit: json['unit'],
      notes: json['notes'],
    );
  }
} 