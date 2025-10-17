import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

// API Service Provider - Singleton to ensure single instance across app
final apiServiceProvider = Provider((ref) {
  AppLogger.debug('ApiServiceProvider: Creating ApiService instance');
  return ApiService();
});

// Auth Service Provider
final authServiceProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthService(apiService);
});

// Auth State Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref.read(authServiceProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    AppLogger.info('AuthNotifier: Initializing, checking auth status');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        AppLogger.info(
          'AuthNotifier: Found existing user session: ${user.username}',
        );
      } else {
        AppLogger.info('AuthNotifier: No existing user session found');
      }
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthNotifier: Error checking auth status',
        e,
        stackTrace,
      );
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(String username, String password) async {
    AppLogger.info('AuthNotifier: Login requested for: $username');
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(username, password);
      state = AsyncValue.data(user);
      AppLogger.info('AuthNotifier: Login state updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('AuthNotifier: Login failed', e, stackTrace);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    AppLogger.info('AuthNotifier: Logout requested');
    await _authService.logout();
    state = const AsyncValue.data(null);
    AppLogger.info('AuthNotifier: Logout completed, state cleared');
  }

  Future<void> refreshUser() async {
    AppLogger.info('AuthNotifier: Refreshing user data');
    try {
      final user = await _authService.getMe();
      state = AsyncValue.data(user);
      AppLogger.info('AuthNotifier: User data refreshed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthNotifier: Failed to refresh user data',
        e,
        stackTrace,
      );
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});

// Helper provider to get current user role
final userRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user?.role, orElse: () => null);
});

// Helper provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user, orElse: () => null);
});
