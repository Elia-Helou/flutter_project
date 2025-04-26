import 'base_model.dart';

class Food extends BaseModel {
  final String name;
  final String description;
  final String category; // e.g., fruits, vegetables, meats, etc.
  final String? imageUrl;
  final double servingSize; // in grams
  final String servingUnit; // g, ml, oz, etc.
  final double calories;
  final double protein; // in grams
  final double carbohydrates; // in grams
  final double fats; // in grams
  final double fiber; // in grams
  final double sugar; // in grams
  final double sodium; // in mg
  final List<String> nutrients; // additional nutrients
  final bool isVerified; // whether the food data is verified by nutritionists

  Food({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.nutrients,
    this.isVerified = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'nutrients': nutrients,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['image_url'],
      servingSize: json['serving_size'].toDouble(),
      servingUnit: json['serving_unit'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbohydrates: json['carbohydrates'].toDouble(),
      fats: json['fats'].toDouble(),
      fiber: json['fiber'].toDouble(),
      sugar: json['sugar'].toDouble(),
      sodium: json['sodium'].toDouble(),
      nutrients: List<String>.from(json['nutrients']),
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 