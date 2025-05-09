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
              // TODO: Show add food/recipe modal
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