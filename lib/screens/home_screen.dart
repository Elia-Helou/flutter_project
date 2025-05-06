import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';
import './favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseService.instance.fetchCategoriesWithImage();
  }

  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Already on Home, do nothing
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        // Navigator.pushNamed(context, '/add');
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user != null ? user.firstName : 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Clear any stored credentials if needed
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hello $userName,',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7AC47F), // Green shade
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find, track and eat heathy food.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Article Card (static demo)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // TODO: Replace with your own image asset
                      Image.asset('assets/images/article_burger.png', height: 60, width: 60, fit: BoxFit.cover),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ARTICLE', style: TextStyle(fontSize: 12, color: Colors.red)),
                            const SizedBox(height: 4),
                            const Text('The pros and cons of fast food.', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                elevation: 0,
                              ),
                              child: const Text('Read Now', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Progress Card (static demo)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFFB6A9E5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Track Your\nWeekly Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('View Now', style: TextStyle(color: Color(0xFFB6A9E5))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Choose Your Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No categories found.');
                    }
                    final categories = snapshot.data!;
                    final pastelColors = [
                      Color(0xFFF6FDF7), // greenish
                      Color(0xFFFFF7F6), // pinkish
                      Color(0xFFFFFBEA), // yellowish
                      Color(0xFFF6FAFF), // blueish
                    ];
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final imageUrl = cat['image_url'] ?? '';
                        final categoryName = cat['categories'] ?? '';
                        final assetMap = {
                          'Pizza': 'assets/images/categories/pizza.jpg',
                          'Salad': 'assets/images/categories/salad.jpg',
                          'Burger': 'assets/images/categories/burger.jpg',
                          'Dessert': 'assets/images/categories/dessert.jpg',
                          'Chicken': 'assets/images/categories/chicken.jpg',
                        };
                        Widget imageWidget;
                        if (assetMap.containsKey(categoryName)) {
                          imageWidget = Image.asset(assetMap[categoryName]!, height: 56, width: 56, fit: BoxFit.cover);
                        } else if (imageUrl.startsWith('http')) {
                          imageWidget = Image.network(imageUrl, height: 56, width: 56, fit: BoxFit.cover);
                        } else if (imageUrl.startsWith('/recipes/')) {
                          final assetPath = 'assets/images/categories/' + imageUrl.split('/').last;
                          imageWidget = Image.asset(assetPath, height: 56, width: 56, fit: BoxFit.cover);
                        } else if (imageUrl.startsWith('assets/')) {
                          imageWidget = Image.asset(imageUrl, height: 56, width: 56, fit: BoxFit.cover);
                        } else {
                          imageWidget = const Icon(Icons.fastfood, size: 56, color: Colors.grey);
                        }
                        final pastelColor = pastelColors[i % pastelColors.length];
                        return Container(
                          decoration: BoxDecoration(
                            color: pastelColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(child: imageWidget),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                categoryName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: AppColors.splashBackground,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            // To use your own image: Image.asset('assets/images/home_icon.png', height: 28)
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            // To use your own image: Image.asset('assets/images/search_icon.png', height: 28)
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            // To use your own image: Image.asset('assets/images/add_icon.png', height: 28)
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            // To use your own image: Image.asset('assets/images/favorites_icon.png', height: 28)
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            // To use your own image: Image.asset('assets/images/profile_icon.png', height: 28)
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}