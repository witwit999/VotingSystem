import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/app_logger.dart';

class ApiService {
  late final Dio _dio;
  String? _accessToken;

  static const String _accessTokenKey = 'access_token';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            AppLogger.debug(
              'ApiService: Request to ${options.path} with Bearer token',
            );
          } else {
            AppLogger.debug(
              'ApiService: Request to ${options.path} without token',
            );
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          AppLogger.warning(
            'ApiService: Request failed to ${error.requestOptions.path} - Status: ${error.response?.statusCode}',
          );

          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            AppLogger.info(
              'ApiService: Received 401, attempting token refresh',
            );
            try {
              // Attempt to refresh token
              final refreshed = await _refreshToken();
              if (refreshed) {
                AppLogger.info(
                  'ApiService: Token refreshed successfully, retrying request',
                );
                // Retry the original request
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } else {
                AppLogger.warning('ApiService: Token refresh failed');
              }
            } catch (e) {
              AppLogger.error('ApiService: Error during token refresh', e);
              // If refresh fails, pass the error through
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    return _accessToken;
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't send expired token
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        await prefs.setString(_accessTokenKey, newAccessToken);
        _accessToken = newAccessToken;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void updateAccessToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  String? getErrorMessage(DioException error) {
    // Try to extract error message from response
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        // Handle backend error envelope format
        if (data.containsKey('message')) {
          return data['message'] as String;
        }
        if (data.containsKey('code')) {
          return '${data['code']}: ${data['message'] ?? 'Unknown error'}';
        }
      }
    }

    // Fallback to generic error messages
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return 'Access forbidden.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed with status code: $statusCode';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.put(path, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.delete(path, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }
}
