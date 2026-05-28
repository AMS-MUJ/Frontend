import 'package:ams_try2/core/config/app_config.dart';
import 'package:ams_try2/core/navigation/navigation_service.dart';
import 'package:ams_try2/core/network/api_routes.dart';
import 'package:ams_try2/core/storage/secure_storage.dart';
import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioClient {
  late final Dio dio;

  bool _isRefreshing = false;

  DioClient({required secureStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // =====================================================
        // REQUEST
        // =====================================================
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'AUTH_ACCESS_TOKEN');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        // =====================================================
        // ERROR
        // =====================================================
        onError: (e, handler) async {
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            try {
              final refreshToken = await secureStorage.read(
                key: 'AUTH_REFRESH_TOKEN',
              );

              // ==========================================
              // NO REFRESH TOKEN
              // ==========================================
              if (refreshToken == null || refreshToken.isEmpty) {
                _isRefreshing = false;

                await _forceLogout();

                return handler.reject(e);
              }

              // ==========================================
              // SEPARATE DIO FOR REFRESH
              // ==========================================
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: AppConfig.baseUrl,
                  headers: {'Content-Type': 'application/json'},
                ),
              );

              final refreshResponse = await refreshDio.post(
                ApiRoutes.refresh,
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken = refreshResponse.data['access_token'];

              final newRefreshToken = refreshResponse.data['refresh_token'];

              // ==========================================
              // SAVE NEW ACCESS TOKEN
              // ==========================================
              await secureStorage.write(
                key: 'AUTH_ACCESS_TOKEN',
                value: newAccessToken,
              );

              // ==========================================
              // SAVE NEW REFRESH TOKEN IF PROVIDED
              // ==========================================
              if (newRefreshToken != null) {
                await secureStorage.write(
                  key: 'AUTH_REFRESH_TOKEN',
                  value: newRefreshToken,
                );
              }

              // ==========================================
              // RETRY ORIGINAL REQUEST
              // ==========================================
              final requestOptions = e.requestOptions;

              requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // ==========================================
              // REBUILD MULTIPART FORM DATA
              // ==========================================
              if (requestOptions.extra['isMultipart'] == true) {
                requestOptions.data = await _rebuildFormData(requestOptions);
              }

              final retryResponse = await dio.fetch(requestOptions);

              _isRefreshing = false;

              return handler.resolve(retryResponse);
            } catch (err) {
              debugPrint('REFRESH TOKEN FAILED: $err');

              _isRefreshing = false;

              await _forceLogout();

              return handler.reject(e);
            }
          }

          return handler.next(e);
        },
      ),
    );

    // =====================================================
    // LOGGING
    // =====================================================
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  // =====================================================
  // FORCE LOGOUT
  // =====================================================
  Future<void> _forceLogout() async {
    await _clearSession();

    NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // =====================================================
  // CLEAR SESSION
  // =====================================================
  Future<void> _clearSession() async {
    await secureStorage.delete(key: 'AUTH_ACCESS_TOKEN');

    await secureStorage.delete(key: 'AUTH_REFRESH_TOKEN');

    await secureStorage.delete(key: 'AUTH_TOKEN_TYPE');

    await secureStorage.delete(key: 'AUTH_USER');
  }

  Future<FormData> _rebuildFormData(RequestOptions requestOptions) async {
    final imagePaths = requestOptions.extra['imagePaths'] as List<String>;

    final formData = FormData();

    for (final path in imagePaths) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(path)),
      );
    }

    return formData;
  }
}
