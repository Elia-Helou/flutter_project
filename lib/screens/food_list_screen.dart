import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/database_service.dart';

class FoodListScreen extends StatefulWidget {
  final String category;

  const FoodListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  late Future<List<Map<String, dynamic>>> _foodsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _foodsFuture = _fetchFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchFoods() {
    return DatabaseService.instance.fetchFoodsByCategory(
      widget.category,
      searchQuery: _searchQuery,
    );
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _foodsFuture = _fetchFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.category}...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Foods List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _foodsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No foods found in ${widget.category}'
                              : 'No foods found for "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final foods = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    // Use the food's name for the image instead of category
                    final foodImageUrl = 'assets/images/foods/${food['name'].toString().toLowerCase().replaceAll(' ', '_')}.jpg';
                    final categoryImageUrl = 'assets/images/foods/${widget.category.toLowerCase()}.jpg';
                    final defaultImageUrl = 'assets/images/foods/default_food.jpg';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.asset(
                              foodImageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // If food image fails, try category image
                                return Image.asset(
                                  categoryImageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // If category image fails, try default image
                                    return Image.asset(
                                      defaultImageUrl,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // If all images fail, show a placeholder
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 64,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          // Food Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  food['description'] ?? 'No description available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Nutrition Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildNutritionInfo('Calories', '${food['calories']}'),
                                    _buildNutritionInfo('Protein', '${food['protein']}g'),
                                    _buildNutritionInfo('Carbs', '${food['carbohydrates']}g'),
                                    _buildNutritionInfo('Fats', '${food['fats']}g'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Serving Size: ${food['serving_size']} ${food['serving_unit']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 