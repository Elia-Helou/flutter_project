import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoodRecognitionService {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  static const String _calorieNinjasUrl = 'https://api.calorieninjas.com/v1/nutrition';

  Future<String> recognizeFood(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/classify'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['result'];
        } else {
          throw Exception(jsonResponse['error'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception('Failed to recognize food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error recognizing food: $e');
    }
  }

  Future<Map<String, dynamic>> getNutritionalInfo(String foodName) async {
    try {
      final response = await http.get(
        Uri.parse('$_calorieNinjasUrl?query=$foodName'),
        headers: {
          'X-Api-Key': dotenv.env['CALORIE_NINJAS_API_KEY'] ?? '',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get nutritional info: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting nutritional info: $e');
    }
  }
} 