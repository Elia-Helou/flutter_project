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
}