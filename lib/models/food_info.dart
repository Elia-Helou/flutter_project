class FoodInfo {
  final String name;
  final double calories;
  final double servingSize;
  final String servingUnit;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double sugar;

  FoodInfo({
    required this.name,
    required this.calories,
    required this.servingSize,
    required this.servingUnit,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    required this.sugar,
  });

  factory FoodInfo.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List;
    if (items.isEmpty) {
      throw Exception('No food information found');
    }
    
    final item = items[0];
    return FoodInfo(
      name: item['name'] ?? 'Unknown',
      calories: (item['calories'] ?? 0.0).toDouble(),
      servingSize: (item['serving_size_g'] ?? 0.0).toDouble(),
      servingUnit: 'g',
      protein: (item['protein_g'] ?? 0.0).toDouble(),
      fat: (item['fat_total_g'] ?? 0.0).toDouble(),
      carbohydrates: (item['carbohydrates_total_g'] ?? 0.0).toDouble(),
      fiber: (item['fiber_g'] ?? 0.0).toDouble(),
      sugar: (item['sugar_g'] ?? 0.0).toDouble(),
    );
  }
} 