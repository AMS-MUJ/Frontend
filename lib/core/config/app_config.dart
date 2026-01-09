import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not set in .env');
    }
    return url;
  }

  static String get mockApiUrl {
    final url = dotenv.env['MOCK_API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('MOCK_API_URL not set in .env');
    }
    return url;
  }
}
