import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // Login method
  Future<User?> login(String email, String password) async {
    try {
      final conn = await connection;
      final result = await conn.execute(
        'SELECT * FROM users WHERE email = @email AND password = @password',
        parameters: {
          'email': email,
          'password': password,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final userData = result.first.toColumnMap();
      return User.fromMap(userData);
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Signup method
  Future<User?> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String height,
    required String weight,
    required String goalWeight,
    required String activityLevel,
    required String goal,
  }) async {
    try {
      final conn = await connection;
      
      // Check if email already exists
      final checkResult = await conn.execute(
        'SELECT id FROM users WHERE email = @email',
        parameters: {'email': email},
      );
      
      if (checkResult.isNotEmpty) {
        throw Exception('Email already exists');
      }

      // Insert new user
      final result = await conn.execute(
        '''
        INSERT INTO users (
          email, password, first_name, last_name, phone_number,
          gender, date_of_birth, height, weight, goal_weight,
          activity_level, goal, created_at, updated_at
        ) VALUES (
          @email, @password, @firstName, @lastName, @phoneNumber,
          @gender, @dateOfBirth, @height, @weight, @goalWeight,
          @activityLevel, @goal, NOW(), NOW()
        ) RETURNING *
        ''',
        parameters: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'height': height,
          'weight': weight,
          'goalWeight': goalWeight,
          'activityLevel': activityLevel,
          'goal': goal,
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
}