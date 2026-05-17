import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_routes.dart';

class ApiClient {
  late final Dio dio;

  bool _isRefreshing = false;

  ApiClient() {
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
        // =========================
        // REQUEST
        // =========================
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'AUTH_ACCESS_TOKEN');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        // =========================
        // ERROR
        // =========================
        onError: (e, handler) async {
          // Token expired
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            try {
              final refreshToken = await secureStorage.read(
                key: 'AUTH_REFRESH_TOKEN',
              );

              if (refreshToken == null || refreshToken.isEmpty) {
                await _clearSession();
                return handler.next(e);
              }

              // Call refresh API
              final refreshResponse = await dio.post(
                ApiRoutes.refresh,
                data: {'refresh_token': refreshToken},
                options: Options(headers: {'Authorization': null}),
              );

              final newAccessToken = refreshResponse.data['access_token'];

              // Save new access token
              await secureStorage.write(
                key: 'AUTH_ACCESS_TOKEN',
                value: newAccessToken,
              );

              // Retry original request
              final requestOptions = e.requestOptions;

              requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(requestOptions);

              _isRefreshing = false;

              return handler.resolve(retryResponse);
            } catch (_) {
              _isRefreshing = false;

              await _clearSession();

              return handler.next(e);
            }
          }

          return handler.next(e);
        },
      ),
    );

    // =========================
    // LOGGING
    // =========================
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  // =========================
  // CLEAR SESSION
  // =========================
  Future<void> _clearSession() async {
    await secureStorage.delete(key: 'AUTH_ACCESS_TOKEN');

    await secureStorage.delete(key: 'AUTH_REFRESH_TOKEN');

    await secureStorage.delete(key: 'AUTH_TOKEN_TYPE');

    await secureStorage.delete(key: 'AUTH_USER');
  }

  // =========================
  // GET
  // =========================
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // POST
  // =========================
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // PUT
  // =========================
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // ERROR HANDLER
  // =========================
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return Exception(data['detail'] ?? data['message'] ?? 'Server error');
      }

      return Exception('API_ERROR_${e.response?.statusCode}');
    }

    return Exception('Network error');
  }
}
