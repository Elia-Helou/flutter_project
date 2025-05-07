import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/database_service.dart';
import '../screens/recipe_list_screen.dart';
import '../screens/food_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<String>> _recipesCategoriesFuture;
  late Future<List<String>> _foodCategoriesFuture;
  final TextEditingController _recipeCategorySearchController = TextEditingController();
  final TextEditingController _foodCategorySearchController = TextEditingController();
  String _recipeCategorySearchQuery = '';
  String _foodCategorySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recipesCategoriesFuture = _fetchRecipeCategories();
    _foodCategoriesFuture = _fetchFoodCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipeCategorySearchController.dispose();
    _foodCategorySearchController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchRecipeCategories() async {
    return DatabaseService.instance.fetchDistinctCategories();
  }

  Future<List<String>> _fetchFoodCategories() async {
    return DatabaseService.instance.fetchDistinctFoodCategories();
  }

  void _onRecipeCategorySearch() {
    setState(() {
      _recipeCategorySearchQuery = _recipeCategorySearchController.text.trim().toLowerCase();
    });
  }

  void _onFoodCategorySearch() {
    setState(() {
      _foodCategorySearchQuery = _foodCategorySearchController.text.trim().toLowerCase();
    });
  }

  List<String> _filterCategories(List<String> categories, String query) {
    if (query.isEmpty) {
      return categories;
    }
    return categories.where(
      (category) => category.toLowerCase().contains(query)
    ).toList();
  }

  Widget _buildCategoryCard(String category, String type, {required Function(String) onTap}) {
    String imageUrl = type == 'recipe' 
      ? 'assets/images/categories/${category.toLowerCase()}.jpg'
      : 'assets/images/foods/${category.toLowerCase()}.jpg';
    String defaultImageUrl = type == 'recipe'
      ? 'assets/images/categories/default_recipe.jpg'
      : 'assets/images/foods/default_food.jpg';
    
    return GestureDetector(
      onTap: () => onTap(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Image
              Image.asset(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    defaultImageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(
                          type == 'recipe' ? Icons.restaurant_menu : Icons.restaurant,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  );
                },
              ),
              // Dark overlay
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              // Category text centered
              Positioned.fill(
                child: Center(
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 6,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.splashBackground,
          labelColor: AppColors.splashBackground,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Food Search'),
            Tab(text: 'Recipes Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Food Search Tab
          Column(
            children: [
              // Search Bar for Food Categories
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _foodCategorySearchController,
                        decoration: InputDecoration(
                          hintText: 'Search foods categories...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onSubmitted: (_) => _onFoodCategorySearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onFoodCategorySearch,
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
              // Food Categories List
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _foodCategoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No foods categories found'));
                    }

                    final filteredCategories = _filterCategories(snapshot.data!, _foodCategorySearchQuery);

                    if (filteredCategories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found for "${_foodCategorySearchController.text}"',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return _buildCategoryCard(
                          category,
                          'foods',
                          onTap: (category) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodListScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Recipes Search Tab
          Column(
            children: [
              // Search Bar for Recipe Categories
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _recipeCategorySearchController,
                        decoration: InputDecoration(
                          hintText: 'Search recipe categories...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onSubmitted: (_) => _onRecipeCategorySearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onRecipeCategorySearch,
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
              // Recipe Categories List
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _recipesCategoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No recipe categories found'));
                    }

                    final allCategories = ['My Recipes', ...snapshot.data!];
                    final filteredCategories = _filterCategories(allCategories, _recipeCategorySearchQuery);

                    if (filteredCategories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found for "${_recipeCategorySearchController.text}"',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return _buildCategoryCard(
                          category,
                          'recipe',
                          onTap: (category) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeListScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 