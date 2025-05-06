import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/database_service.dart';
import '../screens/recipe_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<String>> _categoriesFuture;
  final TextEditingController _categorySearchController = TextEditingController();
  String _categorySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoriesFuture = _fetchCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchCategories() async {
    final results = await DatabaseService.instance.fetchDistinctCategories();
    return results;
  }

  void _onCategorySearch() {
    setState(() {
      _categorySearchQuery = _categorySearchController.text.trim().toLowerCase();
    });
  }

  List<String> _filterCategories(List<String> categories) {
    if (_categorySearchQuery.isEmpty) {
      return categories;
    }
    return categories.where(
      (category) => category.toLowerCase().contains(_categorySearchQuery)
    ).toList();
  }

  Widget _buildCategoryCard(String category) {
    String imageUrl = 'assets/images/categories/${category.toLowerCase()}.jpg';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeListScreen(category: category),
          ),
        );
      },
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
                      fontSize: 32, // Bigger font size
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Food search results will appear here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Recipes Search Tab
          Column(
            children: [
              // Search Bar for Categories
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _categorySearchController,
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
                        onSubmitted: (_) => _onCategorySearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onCategorySearch,
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
              // Categories List
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No categories found'));
                    }

                    final allCategories = ['My Recipes', ...snapshot.data!];
                    final filteredCategories = _filterCategories(allCategories);

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
                              'No categories found for "${_categorySearchController.text}"',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(filteredCategories[index]);
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