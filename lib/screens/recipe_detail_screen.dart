import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../core/constants/colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeName;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeName,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Map<String, dynamic>?> _recipeFuture;
  bool _isMetric = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _recipeFuture = DatabaseService.instance.fetchRecipeDetails(widget.recipeName);
  }

  String _formatUnit(String unit, dynamic amount) {
    // Convert amount to double safely
    final double numAmount = double.tryParse(amount?.toString() ?? '0') ?? 0;
    
    if (_isMetric) {
      switch (unit.toLowerCase()) {
        case 'oz':
          return '${(numAmount * 28.35).round()}g';
        case 'lb':
          return '${(numAmount * 0.45359237).toStringAsFixed(1)}kg';
        case 'cup':
          return '${(numAmount * 236.588).round()}ml';
        default:
          return '$numAmount $unit';
      }
    }
    return '$numAmount $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Recipe not found'));
          }

          final recipe = snapshot.data!;
          final ingredients = (recipe['ingredients'] as List<dynamic>?) ?? [];

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/recipes/${recipe['image_url']}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, size: 64),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),

              // Recipe Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        recipe['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recipe Info Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard(
                            icon: Icons.people,
                            label: 'Servings',
                            value: '${recipe['servings'] ?? 0}',
                          ),
                          _buildInfoCard(
                            icon: Icons.timer,
                            label: 'Prep Time',
                            value: '${recipe['preparation_time'] ?? 0} min',
                          ),
                          _buildInfoCard(
                            icon: Icons.local_fire_department,
                            label: 'Calories',
                            value: '${(double.tryParse(recipe['total_calories']?.toString() ?? '0') ?? 0).round()}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ingredients Section
                      // Ingredients Section
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = ingredients[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record, size: 8),
                                const SizedBox(width: 8),
                                Text(
                                  '${_formatUnit(
                                    ingredient['unit'] ?? '',
                                    ingredient['amount'],
                                  )} ${ingredient['food_name']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Instructions
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe['instructions'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 