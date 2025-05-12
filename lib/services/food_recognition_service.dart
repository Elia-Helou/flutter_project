import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodRecognitionService {
  //final String _baseUrl = 'http://10.0.2.2:5000';
  final String _baseUrl = 'http://127.0.0.1:5000';

  static const String _calorieNinjasUrl = 'https://api.calorieninjas.com/v1/nutrition';

  Future<Map<String, String>> recognizeFood(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/classify'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final result = jsonResponse['result'];
          return {
            'detected_food': result['detected_food'] ?? '',
            'nutrition_facts': result['nutrition_facts'] ?? '',
          };
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
          'X-Api-Key': '',
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