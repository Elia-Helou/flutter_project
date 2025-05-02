 import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}