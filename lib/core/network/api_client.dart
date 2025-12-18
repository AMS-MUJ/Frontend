import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> get(String url) async {
    final token = await _storage.read(key: 'token');
    print("TOKEN SENT: $token");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error ${response.statusCode}');
    }
  }
}
