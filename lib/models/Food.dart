import 'base_model.dart';

class Food extends BaseModel {
  final String name;
  final String? description;
  final String category;
  final String? imageUrl;
  final double? servingSize;
  final String? servingUnit;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;

  Food({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.description,
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
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['image_url'],
      servingSize: json['serving_size'],
      servingUnit: json['serving_unit'],
      calories: json['calories'],
      protein: json['protein'],
      carbohydrates: json['carbohydrates'],
      fats: json['fats'],
      fiber: json['fiber'],
      sugar: json['sugar'],
      sodium: json['sodium'],
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

}