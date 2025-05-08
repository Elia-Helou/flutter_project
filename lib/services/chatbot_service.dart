import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Or your PC IP for device

  Future<String> askGemini(String question) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'question': question}),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return jsonResponse['result'];
      } else {
        throw Exception(jsonResponse['error'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
} 