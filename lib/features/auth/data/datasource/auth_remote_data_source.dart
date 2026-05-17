import 'dart:convert';

import 'package:ams_try2/core/network/api_routes.dart';
import 'package:ams_try2/features/auth/data/models/auth_model.dart';
import 'package:dio/dio.dart';

/// Thrown when the remote call fails or the backend returns a non-approved result.
class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error']);

  @override
  String toString() => 'ServerException: $message';
}

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data == null ||
          data['access_token'] == null ||
          data['refresh_token'] == null ||
          data['user'] == null) {
        throw ServerException('Invalid response structure');
      }

      return AuthModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw ServerException('Network error');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
