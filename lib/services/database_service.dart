import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Connection? _connection;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Connection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await _initConnection();
    await _initializeDatabase();
    return _connection!;
  }

  Future<Connection> _initConnection() async {
    try {
      await dotenv.load();

      final host = dotenv.env['DB_HOST'] ?? 'localhost';
      final port = int.parse(dotenv.env['DB_PORT'] ?? '5432');
      final database = dotenv.env['DB_NAME'] ?? '';
      final username = dotenv.env['DB_USERNAME'] ?? '';
      final password = dotenv.env['DB_PASSWORD'] ?? '';

      final endpoint = Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      );

      final conn = await Connection.open(endpoint, settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ));

      return conn;
    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final conn = await connection;
      
      // Create users table
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          email VARCHAR(255) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          first_name VARCHAR(100) NOT NULL,
          last_name VARCHAR(100) NOT NULL,
          date_of_birth DATE NOT NULL,
          gender VARCHAR(20) NOT NULL,
          height DECIMAL(5,2) NOT NULL,
          weight DECIMAL(5,2) NOT NULL,
          activity_level VARCHAR(50),
          profile_image_url VARCHAR(255),
          target_weight DECIMAL(5,2),
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
      ''');
      
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
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
      final result = await conn.execute(
        Sql.named('SELECT * FROM users WHERE email = @email'),
        parameters: {
          'email': email,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final userData = result.first.toColumnMap();
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
      final checkResult = await conn.execute(
        Sql.named('SELECT id FROM users WHERE email = @email'),
        parameters: {'email': email},
      );
      
      if (checkResult.isNotEmpty) {
        throw Exception('Email already exists');
      }

      // Insert new user
      final result = await conn.execute(
        Sql.named('''
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
        '''),
        parameters: {
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

      final userData = result.first.toColumnMap();
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
      final result = await conn.execute('''
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
      final result = await conn.execute('''
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
      final result = await conn.execute(
        Sql.named('''
        SELECT name, image_url, CAST(total_calories AS INTEGER) as total_calories
        FROM recipes
        WHERE categories = @category
        AND (
          @search = ''
          OR name ILIKE '%' || @search || '%'
        )
        ORDER BY name
        '''),
        parameters: {
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
      final result = await conn.execute(
        Sql.named('''
        SELECT 1 FROM favorite_recipes
        WHERE user_id = @user_id AND recipe_id = @recipe_id
        '''),
        parameters: {
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
      await conn.execute(
        Sql.named('''
        INSERT INTO favorite_recipes (user_id, recipe_id)
        VALUES (@user_id, @recipe_id)
        ON CONFLICT (user_id, recipe_id) DO NOTHING
        '''),
        parameters: {
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
      await conn.execute(
        Sql.named('''
        DELETE FROM favorite_recipes
        WHERE user_id = @user_id AND recipe_id = @recipe_id
        '''),
        parameters: {
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
      final recipeResult = await conn.execute(
        Sql.named('''
        SELECT *
        FROM recipes
        WHERE name = @name
        LIMIT 1
        '''),
        parameters: {'name': recipeName},
      );

      if (recipeResult.isEmpty) {
        return null;
      }

      final recipeData = recipeResult.first.toColumnMap();

      // Fetch ingredients separately
      final ingredientsResult = await conn.execute(
        Sql.named('''
        SELECT f.name as food_name, ri.amount, ri.unit
        FROM recipe_ingredients ri
        JOIN recipes r ON r.id = ri.recipe_id
        JOIN foods f ON f.id = ri.food_id
        WHERE r.name = @name
        '''),
        parameters: {'name': recipeName},
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
      final result = await conn.execute(
        Sql.named('''
        SELECT r.name, r.image_url, r.total_calories
        FROM recipes r
        JOIN favorite_recipes fr ON r.id = fr.recipe_id
        WHERE fr.user_id = @user_id
        AND (
          @search = ''
          OR r.name ILIKE '%' || @search || '%'
        )
        ORDER BY r.name
        '''),
        parameters: {
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
      final result = await conn.execute('''
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
      final result = await conn.execute(
        Sql.named('''
        SELECT 
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
          CAST(sodium AS DECIMAL(5,1)) as sodium
        FROM foods
        WHERE category = @category
        AND (
          @search = ''
          OR name ILIKE '%' || @search || '%'
        )
        ORDER BY name
        '''),
        parameters: {
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
      await conn.execute(
        Sql.named('''
        UPDATE users
        SET 
          height = @height,
          weight = @weight,
          activity_level = @activityLevel,
          target_weight = @targetWeight,
          updated_at = CURRENT_TIMESTAMP
        WHERE email = @email
        '''),
        parameters: {
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
      await conn.execute(
        Sql.named('''
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
        '''),
        parameters: {
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
}