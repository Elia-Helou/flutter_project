import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';
import '../core/constants/colors.dart';
import 'dart:async';
import 'dart:math';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late Future<void> _loadDataFuture;
  Map<String, dynamic> _totals = {'calories': 0, 'fats': 0, 'protein': 0, 'carbs': 0};
  Map<String, List<Map<String, dynamic>>> _meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snack': [],
  };
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadDiaryData();
  }

  Future<void> _loadDiaryData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    final totals = await DatabaseService.instance.fetchDiaryTotalsForDate(user.id, _today);
    final entries = await DatabaseService.instance.fetchDiaryEntriesForDate(user.id, _today);
    final meals = {
      'Breakfast': <Map<String, dynamic>>[],
      'Lunch': <Map<String, dynamic>>[],
      'Dinner': <Map<String, dynamic>>[],
      'Snack': <Map<String, dynamic>>[],
    };
    for (final entry in entries) {
      final meal = entry['meal_type'] ?? 'Other';
      if (meals.containsKey(meal)) {
        meals[meal]!.add(entry);
      }
    }
    setState(() {
      _totals = {
        'calories': num.tryParse(totals['calories'].toString()) ?? 0,
        'fats': num.tryParse(totals['fats'].toString()) ?? 0,
        'protein': num.tryParse(totals['protein'].toString()) ?? 0,
        'carbs': num.tryParse(totals['carbs'].toString()) ?? 0,
      };
      _meals = meals;
    });
  }

  Future<void> _removeEntry(int entryId) async {
    await DatabaseService.instance.deleteFoodDiaryEntry(entryId);
    await _loadDiaryData();
  }

  Widget _buildSummary() {
    // Example targets, you can fetch from user profile if available
    const int calorieTarget = 1820;
    const int fatTarget = 165;
    const int proteinTarget = 56;
    const int carbTarget = 28;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${_totals['calories']} / $calorieTarget Calories', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            _buildProgressBar(_totals['calories'], calorieTarget, Colors.orange),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('${_totals['fats']} g / $fatTarget g Fats')),
              ],
            ),
            _buildProgressBar(_totals['fats'], fatTarget, Colors.green),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('${_totals['protein']} g / $proteinTarget g Proteins')),
              ],
            ),
            _buildProgressBar(_totals['protein'], proteinTarget, Colors.brown),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('${_totals['carbs']} g / $carbTarget g Carbs')),
              ],
            ),
            _buildProgressBar(_totals['carbs'], carbTarget, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(num value, num max, Color color) {
    final percent = (max > 0) ? (value / max).clamp(0.0, 1.0) : 0.0;
    return LinearProgressIndicator(
      value: percent.toDouble(),
      backgroundColor: color.withOpacity(0.2),
      valueColor: AlwaysStoppedAnimation<Color>(color),
      minHeight: 8,
    );
  }

  Widget _buildMealSection(String meal) {
    final entries = _meals[meal] ?? [];
    final totalMealCalories = entries.fold<num>(
      0,
      (sum, e) => sum + (num.tryParse(e['calories'].toString()) ?? 0),
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ExpansionTile(
        title: Text('$meal  (${totalMealCalories.toStringAsFixed(0)} Cal eaten)', style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          ...entries.map((entry) => ListTile(
                title: Text(_entryName(entry)),
                subtitle: Text('${entry['calories']} Cal'),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _removeEntry(entry['id']),
                ),
              )),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add food or recipe'),
            onTap: () {
              _showAddEntryModal(meal);
            },
          ),
        ],
      ),
    );
  }

  String _entryName(Map<String, dynamic> entry) {
    if (entry['food_id'] != null) {
      return 'Food #${entry['food_id']}'; // You can fetch food name if needed
    } else if (entry['recipe_id'] != null) {
      return 'Recipe #${entry['recipe_id']}'; // You can fetch recipe name if needed
    }
    return '?';
  }

  void _showAddEntryModal(String meal) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddDiaryEntryModal(
        meal: meal,
        onEntryAdded: () async {
          Navigator.of(context).pop();
          await _loadDiaryData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diary"),
      ),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              _buildSummary(),
              _buildMealSection('Breakfast'),
              _buildMealSection('Lunch'),
              _buildMealSection('Dinner'),
              _buildMealSection('Snack'),
            ],
          );
        },
      ),
    );
  }
}

class AddDiaryEntryModal extends StatefulWidget {
  final String meal;
  final VoidCallback onEntryAdded;
  const AddDiaryEntryModal({required this.meal, required this.onEntryAdded, Key? key}) : super(key: key);

  @override
  State<AddDiaryEntryModal> createState() => _AddDiaryEntryModalState();
}

class _AddDiaryEntryModalState extends State<AddDiaryEntryModal> {
  String _type = 'Food';
  String _search = '';
  String _selectedCategory = '';
  List<String> _categories = [];
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndItems();
  }

  Future<void> _fetchCategoriesAndItems() async {
    setState(() { _loading = true; });
    List<String> categories = [];
    if (_type == 'Food') {
      categories = await DatabaseService.instance.fetchDistinctFoodCategories();
    } else {
      categories = await DatabaseService.instance.fetchDistinctCategories();
    }
    setState(() {
      _categories = categories;
      _selectedCategory = categories.isNotEmpty ? categories[0] : '';
    });
    await _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() { _loading = true; });
    List<Map<String, dynamic>> items = [];
    if (_type == 'Food') {
      if (_selectedCategory.isNotEmpty) {
        items = await DatabaseService.instance.fetchFoodsByCategory(_selectedCategory, searchQuery: _search);
      }
    } else {
      if (_selectedCategory.isNotEmpty) {
        items = await DatabaseService.instance.fetchRecipesByCategory(_selectedCategory, searchQuery: _search);
      }
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _onTypeChanged(String type) async {
    setState(() {
      _type = type;
      _search = '';
      _searchController.clear();
      _categories = [];
      _selectedCategory = '';
      _items = [];
    });
    await _fetchCategoriesAndItems();
  }

  void _onCategorySelected(String category) async {
    setState(() {
      _selectedCategory = category;
    });
    await _fetchItems();
  }

  void _onSearchChanged(String value) async {
    setState(() {
      _search = value;
    });
    await _fetchItems();
  }

  void _onAddPressed(Map<String, dynamic> item) async {
    final quantityController = TextEditingController(text: '1');
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quantity (servings)'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = double.tryParse(quantityController.text) ?? 1.0;
              Navigator.of(context).pop(q);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _addEntry(item, result);
    }
  }

  Future<void> _addEntry(Map<String, dynamic> item, double quantity) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    final now = DateTime.now();
    try {
      if (_type == 'Food' && item['id'] != null) {
        await DatabaseService.instance.addFoodDiaryEntry(
          userId: user.id,
          date: now,
          mealType: widget.meal,
          foodId: item['id'],
          recipeId: null,
          quantity: quantity,
          calories: (num.tryParse(item['calories'].toString()) ?? 0) * quantity,
          fats: (num.tryParse(item['fats'].toString()) ?? 0) * quantity,
          protein: (num.tryParse(item['protein'].toString()) ?? 0) * quantity,
          carbs: (num.tryParse(item['carbohydrates'].toString()) ?? 0) * quantity,
        );
      } else if (_type == 'Recipe' && item['id'] != null) {
        await DatabaseService.instance.addFoodDiaryEntry(
          userId: user.id,
          date: now,
          mealType: widget.meal,
          foodId: null,
          recipeId: item['id'],
          quantity: quantity,
          calories: (num.tryParse(item['total_calories'].toString()) ?? 0) * quantity,
          fats: (num.tryParse(item['total_fats'].toString()) ?? 0) * quantity,
          protein: (num.tryParse(item['total_protein'].toString()) ?? 0) * quantity,
          carbs: (num.tryParse(item['total_carbohydrates'].toString()) ?? 0) * quantity,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid food or recipe.')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added successfully!'), backgroundColor: Colors.green),
      );
      widget.onEntryAdded();
    } catch (e) {
      print('Error adding diary entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding entry: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Tabs with icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _onTypeChanged('Food'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _type == 'Food' ? Colors.grey[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_food_beverage, size: 32),
                        const SizedBox(width: 8),
                        const Text('Foods'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _onTypeChanged('Recipe'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _type == 'Recipe' ? Colors.grey[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, size: 32),
                        const SizedBox(width: 8),
                        const Text('Recipes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 8),
            // Category chips
            if (_categories.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => _onCategorySelected(cat),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            // List of foods/recipes
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No items found.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  final name = item['name'] ?? '';
                  final cal = _type == 'Food' ? item['calories'] : item['total_calories'];
                  final img = item['image_url'] ?? '';
                  return Card(
                    child: ListTile(
                      leading: img != ''
                          ? Image.network(img, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood))
                          : const Icon(Icons.fastfood, size: 40),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$cal Cal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, size: 28),
                        onPressed: () => _onAddPressed(item),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 