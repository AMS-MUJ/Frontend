import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  Future<Map<String, dynamic>> get(String path) async {
    final token = await secureStorage.read(key: 'token');

    if (token == null || token.isEmpty) {
      throw Exception('AUTH_TOKEN_MISSING');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}$path');

    final response = await http.get(
      uri,
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else {
      throw Exception('API_ERROR_${response.statusCode}');
    }
  }
}
