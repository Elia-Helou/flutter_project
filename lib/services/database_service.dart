import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static DatabaseService? _instance;
  PostgreSQLConnection? _connection;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _connection!.isClosed == false) return _connection!;
    _connection = await _initConnection();
    return _connection!;
  }

  Future<PostgreSQLConnection> _initConnection() async {
    try {
      await dotenv.load();

      final host = dotenv.env['DB_HOST'] ?? 'localhost';
      final port = int.parse(dotenv.env['DB_PORT'] ?? '5432');
      final database = dotenv.env['DB_NAME'] ?? '';
      final username = dotenv.env['DB_USERNAME'] ?? '';
      final password = dotenv.env['DB_PASSWORD'] ?? '';

      final conn = PostgreSQLConnection(
        host,
        port,
        database,
        username: username,
        password: password,
        useSSL: false,
      );
      await conn.open();
      return conn;
    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // Login method
  Future<User?> login(String email, String password) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        'SELECT * FROM users WHERE email = @email',
        substitutionValues: {'email': email},
      );
      if (result.isEmpty) {
        return null;
      }
      final userData = Map<String, dynamic>.from(result.first.toColumnMap());
      return User.fromMap(userData);
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  // Signup method
  Future<User?> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required int phoneNumber,
    String? activityLevel,
    String? targetWeight,
  }) async {
    try {
      final conn = await connection;
      // Check if email already exists
      final checkResult = await conn.query(
        'SELECT id FROM users WHERE email = @email',
        substitutionValues: {'email': email},
      );
      if (checkResult.isNotEmpty) {
        throw Exception('Email already exists');
      }
      // Insert new user
      final result = await conn.query(
        '''
        INSERT INTO users (
          email, password, first_name, last_name,
          gender, date_of_birth, height, weight,
          phone_number,
          activity_level, target_weight
        ) VALUES (
          @email, @password, @firstName, @lastName,
          @gender, @dateOfBirth, @height, @weight,
          @phoneNumber,
          @activityLevel, @targetWeight
        ) RETURNING *
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'height': height,
          'weight': weight,
          'phoneNumber': phoneNumber,
          'activityLevel': activityLevel,
          'targetWeight': targetWeight,
        },
      );
      if (result.isEmpty) {
        return null;
      }
      final userData = Map<String, dynamic>.from(result.first.toColumnMap());
      return User.fromMap(userData);
    } catch (e) {
      print('Error during signup: $e');
      rethrow;
    }
  }

  // Fetch unique categories with one image per category from recipes table
  Future<List<Map<String, dynamic>>> fetchCategoriesWithImage() async {
    try {
      final conn = await connection;
      // Fetch unique categories and one image_url per category
      final result = await conn.query('''
        SELECT categories, MIN(image_url) AS image_url
        FROM recipes
        WHERE categories IS NOT NULL AND categories != ''
        GROUP BY categories
      ''');
      final mapped = result.map((row) => row.toColumnMap()).toList();
      print('Fetched categories:');
      for (final row in mapped) {
        print(row);
      }
      return mapped;
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  // Fetch distinct categories from recipes table
  Future<List<String>> fetchDistinctCategories() async {
    try {
      final conn = await connection;
      final result = await conn.query('''
        SELECT DISTINCT categories
        FROM recipes
        WHERE categories IS NOT NULL AND categories != ''
        ORDER BY categories
      ''');
      
      return result.map((row) => row[0] as String).toList();
    } catch (e) {
      print('Error fetching distinct categories: $e');
      rethrow;
    }
  }

  // Fetch recipes by category
  Future<List<Map<String, dynamic>>> fetchRecipesByCategory(String category, {String searchQuery = ''}) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        '''
        SELECT id, name, image_url, CAST(total_calories AS INTEGER) as total_calories, CAST(total_protein AS DECIMAL(5,1)) as total_protein, CAST(total_fats AS DECIMAL(5,1)) as total_fats, CAST(total_carbohydrates AS DECIMAL(5,1)) as total_carbohydrates
        FROM recipes
        WHERE categories = @category
        AND (
          @search = ''
          OR name ILIKE '%' || @search || '%'
        )
        ORDER BY name
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'category': category,
          'search': searchQuery.trim(),
        },
      );
      
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('Error fetching recipes by category: $e');
      rethrow;
    }
  }

  // Check if a recipe is favorited by user
  Future<bool> isRecipeFavorited(int userId, int recipeId) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        '''
        SELECT 1 FROM favorite_recipes
        WHERE user_id = @user_id AND recipe_id = @recipe_id
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'user_id': userId,
          'recipe_id': recipeId,
        },
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Add recipe to favorites
  Future<void> addToFavorites(int userId, int recipeId) async {
    try {
      final conn = await connection;
      await conn.query('''
        INSERT INTO favorite_recipes (user_id, recipe_id)
        VALUES (@user_id, @recipe_id)
        ON CONFLICT (user_id, recipe_id) DO NOTHING
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'user_id': userId,
          'recipe_id': recipeId,
        },
      );
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove recipe from favorites
  Future<void> removeFromFavorites(int userId, int recipeId) async {
    try {
      final conn = await connection;
      await conn.query('''
        DELETE FROM favorite_recipes
        WHERE user_id = @user_id AND recipe_id = @recipe_id
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'user_id': userId,
          'recipe_id': recipeId,
        },
      );
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Modify fetchRecipeDetails to include recipe ID
  Future<Map<String, dynamic>?> fetchRecipeDetails(String recipeName) async {
    try {
      final conn = await connection;
      
      // Fetch recipe details including ID
      final recipeResult = await conn.query(
        '''
        SELECT *
        FROM recipes
        WHERE name = @name
        LIMIT 1
        '''.replaceAll('\n', ' '),
        substitutionValues: {'name': recipeName},
      );

      if (recipeResult.isEmpty) {
        return null;
      }

      final recipeData = Map<String, dynamic>.from(recipeResult.first.toColumnMap());

      // Fetch ingredients separately
      final ingredientsResult = await conn.query(
        '''
        SELECT f.name as food_name, ri.amount, ri.unit
        FROM recipe_ingredients ri
        JOIN recipes r ON r.id = ri.recipe_id
        JOIN foods f ON f.id = ri.food_id
        WHERE r.name = @name
        '''.replaceAll('\n', ' '),
        substitutionValues: {'name': recipeName},
      );

      // Convert ingredients to List<Map>
      final ingredients = ingredientsResult.map((row) => {
        'food_name': row[0],
        'amount': row[1],
        'unit': row[2],
      }).toList();
      
      // Add ingredients to recipe data
      recipeData['ingredients'] = ingredients;
      
      return recipeData;
    } catch (e) {
      print('Error fetching recipe details: $e');
      rethrow;
    }
  }

  // Fetch user's favorite recipes
  Future<List<Map<String, dynamic>>> fetchFavoriteRecipes(int userId, {String searchQuery = ''}) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        '''
        SELECT r.name, r.image_url, r.total_calories
        FROM recipes r
        JOIN favorite_recipes fr ON r.id = fr.recipe_id
        WHERE fr.user_id = @user_id
        AND (
          @search = ''
          OR r.name ILIKE '%' || @search || '%'
        )
        ORDER BY r.name
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'user_id': userId,
          'search': searchQuery.trim(),
        },
      );
      
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('Error fetching favorite recipes: $e');
      rethrow;
    }
  }

  // Fetch distinct foods categories
  Future<List<String>> fetchDistinctFoodCategories() async {
    try {
      final conn = await connection;
      final result = await conn.query('''
        SELECT DISTINCT category
        FROM foods
        WHERE category IS NOT NULL AND category != ''
        ORDER BY category
      ''');
      
      return result.map((row) => row[0] as String).toList();
    } catch (e) {
      print('Error fetching distinct foods categories: $e');
      rethrow;
    }
  }

  // Fetch foods by category
  Future<List<Map<String, dynamic>>> fetchFoodsByCategory(String category, {String searchQuery = ''}) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        '''
        SELECT 
          id,
          name, 
          description, 
          category,
          serving_size,
          serving_unit,
          CAST(calories AS INTEGER) as calories,
          CAST(protein AS DECIMAL(5,1)) as protein,
          CAST(carbohydrates AS DECIMAL(5,1)) as carbohydrates,
          CAST(fats AS DECIMAL(5,1)) as fats,
          CAST(fiber AS DECIMAL(5,1)) as fiber,
          CAST(sugar AS DECIMAL(5,1)) as sugar,
          CAST(sodium AS DECIMAL(5,1)) as sodium,
          image_url
        FROM foods
        WHERE category = @category
        AND (
          @search = ''
          OR name ILIKE '%' || @search || '%'
        )
        ORDER BY name
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'category': category,
          'search': searchQuery.trim(),
        },
      );
      
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('Error fetching foods by category: $e');
      rethrow;
    }
  }

  // Update fitness goals
  Future<void> updateFitnessGoals({
    required String email,
    required String height,
    required String weight,
    required String activityLevel,
    String? targetWeight,
  }) async {
    try {
      final conn = await connection;
      await conn.query(
        '''
        UPDATE users
        SET 
          height = @height,
          weight = @weight,
          activity_level = @activityLevel,
          target_weight = @targetWeight,
          updated_at = CURRENT_TIMESTAMP
        WHERE email = @email
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'email': email,
          'height': height,
          'weight': weight,
          'activityLevel': activityLevel,
          'targetWeight': targetWeight,
        },
      );
    } catch (e) {
      print('Error updating fitness goals: $e');
      rethrow;
    }
  }

  // Save BMI results to user_progress table
  Future<void> saveBMIResults({
    required int userId,
    required double weight,
    required double height,
    required double bmiValue,
  }) async {
    try {
      final conn = await connection;
      await conn.query(
        '''
        INSERT INTO user_progress (
          user_id,
          weight,
          height,
          bmivalue,
          logged_at
        ) VALUES (
          @userId,
          CAST(@weight AS DECIMAL(5,2)),
          CAST(@height AS DECIMAL(5,2)),
          CAST(@bmiValue AS DECIMAL(5,2)),
          CURRENT_TIMESTAMP
        )
        '''.replaceAll('\n', ' '),
        substitutionValues: {
          'userId': userId,
          'weight': weight,
          'height': height,
          'bmiValue': bmiValue,
        },
      );
    } catch (e) {
      print('Error saving BMI results: $e');
      rethrow;
    }
  }

  // Food Diary Methods
  Future<void> addFoodDiaryEntry({
    required int userId,
    required DateTime date,
    required String mealType,
    int? foodId,
    int? recipeId,
    required double quantity,
    required double calories,
    required double fats,
    required double protein,
    required double carbs,
  }) async {
    final conn = await connection;
    await conn.query(
      '''
        INSERT INTO food_diary_entries (
          user_id, date, meal_type, food_id, recipe_id, quantity, calories, fats, protein, carbs
        ) VALUES (
          @userId, @date, @mealType, @foodId, @recipeId, @quantity, @calories, @fats, @protein, @carbs
        )
      '''.replaceAll('\n', ' '),
      substitutionValues: {
        'userId': userId,
        'date': date.toIso8601String().substring(0, 10),
        'mealType': mealType,
        'foodId': foodId,
        'recipeId': recipeId,
        'quantity': quantity,
        'calories': calories,
        'fats': fats,
        'protein': protein,
        'carbs': carbs,
      },
    );
  }

  Future<void> deleteFoodDiaryEntry(int entryId) async {
    final conn = await connection;
    await conn.query(
      'DELETE FROM food_diary_entries WHERE id = @id',
      substitutionValues: {'id': entryId},
    );
  }

  Future<List<Map<String, dynamic>>> fetchDiaryEntriesForDate(int userId, DateTime date) async {
    final conn = await connection;
    final result = await conn.query(
      '''
        SELECT * FROM food_diary_entries
        WHERE user_id = @userId AND date = @date
        ORDER BY meal_type, created_at
      '''.replaceAll('\n', ' '),
      substitutionValues: {
        'userId': userId,
        'date': date.toIso8601String().substring(0, 10),
      },
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>> fetchDiaryTotalsForDate(int userId, DateTime date) async {
    final conn = await connection;
    final result = await conn.query(
      '''
        SELECT 
          COALESCE(SUM(calories),0) AS calories,
          COALESCE(SUM(fats),0) AS fats,
          COALESCE(SUM(protein),0) AS protein,
          COALESCE(SUM(carbs),0) AS carbs
        FROM food_diary_entries
        WHERE user_id = @userId AND date = @date
      '''.replaceAll('\n', ' '),
      substitutionValues: {
        'userId': userId,
        'date': date.toIso8601String().substring(0, 10),
      },
    );
    return result.isNotEmpty ? result.first.toColumnMap() : {'calories': 0, 'fats': 0, 'protein': 0, 'carbs': 0};
  }

  Future<void> clearCache() async {
    try {
      // Close any existing connections
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
      }
      // No other cache to clear
      // Force a new connection on next use
      await connection;
    } catch (e) {
      debugPrint('Error clearing database cache: $e');
      rethrow;
    }
  }
}