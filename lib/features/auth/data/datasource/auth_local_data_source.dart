// lib/features/auth/data/datasources/auth_local_data_source.dart

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';

/// Thrown when reading/writing from secure storage fails.
class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
  @override
  String toString() => 'CacheException: $message';
}

abstract class AuthLocalDataSource {
  /// Cache the given AuthModel (token + user + status) securely.
  Future<void> cacheAuth(AuthModel auth);

  /// Return cached AuthModel if present, otherwise null.
  Future<AuthModel?> getCachedAuth();

  /// Clear cached auth (logout).
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _cacheKey = 'CACHED_AUTH';
  final FlutterSecureStorage secureStorage;

  /// Pass a FlutterSecureStorage instance for easier testing.
  const AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheAuth(AuthModel auth) async {
    try {
      final jsonString = jsonEncode(auth.toJson());
      await secureStorage.write(key: _cacheKey, value: jsonString);
    } catch (e) {
      throw CacheException(
        'Failed to write auth to secure storage: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthModel?> getCachedAuth() async {
    try {
      final raw = await secureStorage.read(key: _cacheKey);
      if (raw == null || raw.isEmpty) return null;

      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthModel.fromJson(map);
    } catch (e) {
      // If parsing fails, clear the corrupted cache and surface a CacheException
      // (or return null depending on how permissive you want to be).
      await clear();
      throw CacheException('Failed to read cached auth: ${e.toString()}');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await secureStorage.delete(key: _cacheKey);
    } catch (e) {
      throw CacheException('Failed to clear cached auth: ${e.toString()}');
    }
  }
}
