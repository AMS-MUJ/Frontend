import 'dart:convert';
import 'package:ams_try2/core/config/app_config.dart';
import 'package:ams_try2/core/network/api_routes.dart';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';

/// Thrown when the remote call fails or the backend returns a non-approved result.
class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error']);

  @override
  String toString() => 'ServerException: $message';
}

/// Remote data source contract for authentication.
abstract class AuthRemoteDataSource {
  /// Sends login credentials to backend and returns an [AuthModel] when the
  /// backend approves the login (status active/approved) and provides a token.
  ///
  /// Throws [ServerException] on HTTP errors, invalid response format, missing token,
  /// or non-approved status.
  Future<AuthModel> login({required String email, required String password});
}

/// Implementation that uses `http.Client`.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}${ApiRoutes.login}',
    ); // adjust endpoint if needed

    http.Response response;
    try {
      response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } on http.ClientException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Network error: ${e.toString()}');
    }

    // HTTP status check
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'HTTP ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw ServerException(message);
    }

    // Parse JSON body
    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (e) {
      throw ServerException('Invalid JSON response');
    }

    if (decodedBody is! Map<String, dynamic>) {
      // Some APIs wrap data under `data` key — try to handle that
      if (decodedBody is Map && decodedBody['data'] is Map<String, dynamic>) {
        decodedBody = decodedBody['data'] as Map<String, dynamic>;
      } else {
        throw ServerException('Unexpected response format');
      }
    }
    // Parse JSON body
    final body = decodedBody;

    // Validate success flag
    if (body['success'] != true) {
      final msg = body['data']?.toString() ?? 'Login failed';
      throw ServerException(msg);
    }

    // Extract auth payload (token + user)
    if (body['message'] is! Map<String, dynamic>) {
      throw ServerException('Invalid auth response structure');
    }

    final authJson = body['message'] as Map<String, dynamic>;

    // Build AuthModel
    final authModel = AuthModel.fromJson(authJson);

    // Validate token
    if (authModel.accessToken.isEmpty) {
      throw ServerException('Token missing in response');
    }

    return authModel;
  }
}
