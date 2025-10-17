import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/app_logger.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthService(this._apiService);

  /// Login with username and password
  /// POST /auth/login
  Future<UserModel> login(String username, String password) async {
    try {
      AppLogger.info('AuthService: Attempting login for username: $username');
      AppLogger.debug(
        'AuthService: API endpoint: ${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
      );
      AppLogger.debug(
        'AuthService: Request body: {"username": "$username", "password": "***"}',
      );

      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: {'username': username, 'password': password},
        options: Options(
          headers: {'Authorization': null}, // Don't send token for login
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.debug('AuthService: Login response received with status 200');

        // Log the full response for debugging
        AppLogger.debug('AuthService: Response data: ${response.data}');

        final data = response.data as Map<String, dynamic>;

        // Log available keys for debugging
        AppLogger.debug('AuthService: Response keys: ${data.keys.toList()}');

        // Extract tokens and user data
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (accessToken == null || refreshToken == null || userData == null) {
          AppLogger.error('AuthService: Missing required fields in response');
          AppLogger.error(
            '  - accessToken: ${accessToken != null ? "✓" : "✗"}',
          );
          AppLogger.error(
            '  - refreshToken: ${refreshToken != null ? "✓" : "✗"}',
          );
          AppLogger.error('  - user: ${userData != null ? "✓" : "✗"}');
          throw Exception('Invalid response format from server');
        }

        AppLogger.debug('AuthService: Tokens extracted, parsing user data');

        // Parse user model
        final user = UserModel.fromJson(userData);

        // Save tokens and user data
        await _saveTokens(accessToken, refreshToken);
        await _saveUser(user);

        AppLogger.info('AuthService: Tokens and user data saved successfully');

        // Update API service token
        _apiService.updateAccessToken(accessToken);

        AppLogger.info(
          'AuthService: Login completed successfully for user: ${user.username} (${user.role})',
        );

        return user;
      } else {
        AppLogger.error(
          'AuthService: Login failed with status code: ${response.statusCode}',
        );
        throw Exception(
          'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);

      // Detailed error logging
      AppLogger.error('AuthService: Login failed with DioException');
      AppLogger.error('  - Error type: ${e.type}');
      AppLogger.error('  - Status code: ${e.response?.statusCode}');
      AppLogger.error('  - Response data: ${e.response?.data}');
      AppLogger.error('  - Error message: ${e.message}');

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        AppLogger.error(
          '  - Network issue: Cannot connect to ${ApiConstants.baseUrl}',
        );
        throw Exception(
          'Cannot connect to server. Please check your network connection and ensure the backend is running.',
        );
      }

      throw Exception(errorMessage ?? 'Login failed. Please try again.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService: Login failed with unexpected error',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get current user profile
  /// GET /auth/me
  Future<UserModel> getMe() async {
    try {
      final response = await _apiService.get(ApiConstants.meEndpoint);

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);

        // Update saved user data
        await _saveUser(user);

        return user;
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      throw Exception(errorMessage ?? 'Failed to get user profile.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Refresh access token
  /// POST /auth/refresh
  Future<String> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.post(
        ApiConstants.refreshEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't send expired token
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;

        // Save new access token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, newAccessToken);

        // Update API service token
        _apiService.updateAccessToken(newAccessToken);

        return newAccessToken;
      } else {
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      throw Exception(errorMessage ?? 'Token refresh failed.');
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    AppLogger.info('AuthService: Logging out user');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);

    // Clear token from API service
    _apiService.clearToken();

    AppLogger.info('AuthService: Logout completed, all tokens cleared');
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Get stored user data
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        // If JSON parsing fails, return null
        return null;
      }
    }
    return null;
  }

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Save tokens to local storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Save user data to local storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
