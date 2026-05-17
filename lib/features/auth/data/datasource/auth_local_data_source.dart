import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

abstract class AuthLocalDataSource {
  Future<void> cacheAuth(AuthModel auth);

  Future<AuthModel?> getCachedAuth();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _accessTokenKey = 'AUTH_ACCESS_TOKEN';
  static const _refreshTokenKey = 'AUTH_REFRESH_TOKEN';
  static const _tokenTypeKey = 'AUTH_TOKEN_TYPE';
  static const _userKey = 'AUTH_USER';

  final FlutterSecureStorage secureStorage;

  const AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheAuth(AuthModel auth) async {
    try {
      // Store tokens
      await secureStorage.write(key: _accessTokenKey, value: auth.accessToken);

      await secureStorage.write(
        key: _refreshTokenKey,
        value: auth.refreshToken,
      );

      await secureStorage.write(key: _tokenTypeKey, value: auth.tokenType);

      final token = await secureStorage.read(key: _accessTokenKey);

      debugPrint('FINAL TOKEN CHECK: $token');

      // Store user
      final userJson = jsonEncode({
        'id': auth.id,
        'name': auth.name,
        'email': auth.email,
        'role': auth.role,
      });

      await secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw CacheException('Failed to cache auth: ${e.toString()}');
    }
  }

  @override
  Future<AuthModel?> getCachedAuth() async {
    try {
      final accessToken = await secureStorage.read(key: _accessTokenKey);

      final refreshToken = await secureStorage.read(key: _refreshTokenKey);

      final tokenType = await secureStorage.read(key: _tokenTypeKey);

      final userRaw = await secureStorage.read(key: _userKey);

      if (accessToken == null || refreshToken == null || userRaw == null) {
        return null;
      }

      final userMap = jsonDecode(userRaw) as Map<String, dynamic>;

      return AuthModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType ?? 'bearer',

        id: userMap['id'] ?? '',
        name: userMap['name'] ?? '',
        email: userMap['email'] ?? '',
        role: userMap['role'] ?? '',
      );
    } catch (e) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await secureStorage.delete(key: _accessTokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
      await secureStorage.delete(key: _tokenTypeKey);
      await secureStorage.delete(key: _userKey);
    } catch (e) {
      throw CacheException('Failed to clear auth: ${e.toString()}');
    }
  }
}
