import 'package:dio/dio.dart';
import '../models/session_model.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/app_logger.dart';
import 'api_service.dart';

class SessionService {
  final ApiService _apiService;

  SessionService(this._apiService);

  /// Get list of sessions with optional status filter
  /// GET /sessions?status=LIVE|DRAFT|PAUSED|CLOSED|ARCHIVED
  Future<List<SessionModel>> getSessions({SessionStatus? status}) async {
    try {
      AppLogger.info(
        'SessionService: Fetching sessions${status != null ? ' with status: ${status.value}' : ''}',
      );
      AppLogger.debug(
        'SessionService: Endpoint: ${ApiConstants.baseUrl}${ApiConstants.sessionsEndpoint}',
      );

      final queryParams = status != null ? {'status': status.value} : null;
      if (queryParams != null) {
        AppLogger.debug('SessionService: Query params: $queryParams');
      }

      final response = await _apiService.get(
        ApiConstants.sessionsEndpoint,
        queryParameters: queryParams,
      );

      AppLogger.debug(
        'SessionService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        AppLogger.debug('SessionService: Sessions received successfully');
        AppLogger.debug('SessionService: Response data: ${response.data}');

        final data = response.data as List<dynamic>;
        AppLogger.debug(
          'SessionService: Parsing ${data.length} session objects',
        );

        final sessions = <SessionModel>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final json = data[i] as Map<String, dynamic>;
            AppLogger.debug(
              'SessionService: Parsing session $i: ${json['name']} (${json['status']})',
            );
            final session = SessionModel.fromJson(json);
            sessions.add(session);
          } catch (e) {
            AppLogger.error('SessionService: Failed to parse session $i', e);
            AppLogger.error('  - Data: ${data[i]}');
          }
        }

        AppLogger.info('SessionService: Loaded ${sessions.length} sessions');
        return sessions;
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to fetch sessions');
      AppLogger.error('  - Error type: ${e.type}');
      AppLogger.error('  - Status code: ${e.response?.statusCode}');
      AppLogger.error('  - Response data: ${e.response?.data}');
      AppLogger.error('  - Request URL: ${e.requestOptions.uri}');
      AppLogger.error('  - Request headers: ${e.requestOptions.headers}');

      if (e.response?.statusCode == 401) {
        AppLogger.error(
          '  ⚠️ UNAUTHORIZED: Token might be missing or invalid!',
        );
        throw Exception('Unauthorized. Please login again.');
      }

      throw Exception(errorMessage ?? 'Failed to load sessions.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionService: Unexpected error fetching sessions',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get session details by ID
  /// GET /sessions/{id}
  Future<SessionModel> getSessionDetails(String sessionId) async {
    try {
      AppLogger.info(
        'SessionService: Fetching session details for ID: $sessionId',
      );

      final response = await _apiService.get(
        ApiConstants.sessionDetailsEndpoint(sessionId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final session = SessionModel.fromJson(data);

        AppLogger.info(
          'SessionService: Session details loaded for: ${session.name}',
        );
        return session;
      } else {
        throw Exception(
          'Failed to load session details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to fetch session details');
      AppLogger.error('  - Session ID: $sessionId');
      AppLogger.error('  - Error: ${e.response?.data}');
      throw Exception(errorMessage ?? 'Failed to load session details.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionService: Unexpected error fetching session details',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Join a session (member action)
  /// POST /sessions/{id}/join
  Future<void> joinSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Joining session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionJoinEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info(
          'SessionService: Successfully joined session: $sessionId',
        );
      } else {
        throw Exception('Failed to join session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to join session');
      AppLogger.error('  - Session ID: $sessionId');
      AppLogger.error('  - Error: ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to join this session.');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Session is not available for joining.');
      }

      throw Exception(errorMessage ?? 'Failed to join session.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionService: Unexpected error joining session',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Leave a session (member action)
  /// POST /sessions/{id}/leave
  Future<void> leaveSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Leaving session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionLeaveEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('SessionService: Successfully left session: $sessionId');
      } else {
        throw Exception('Failed to leave session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to leave session');
      AppLogger.error('  - Session ID: $sessionId');
      throw Exception(errorMessage ?? 'Failed to leave session.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionService: Unexpected error leaving session',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Create a new session (admin only)
  /// POST /sessions
  Future<SessionModel> createSession(String name) async {
    try {
      AppLogger.info('SessionService: Creating new session: $name');

      final response = await _apiService.post(
        ApiConstants.sessionsEndpoint,
        data: {'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final session = SessionModel.fromJson(data);

        AppLogger.info(
          'SessionService: Session created successfully: ${session.id}',
        );
        return session;
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to create session');
      AppLogger.error('  - Error: ${e.response?.data}');
      throw Exception(errorMessage ?? 'Failed to create session.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionService: Unexpected error creating session',
        e,
        stackTrace,
      );
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Open a session (admin only)
  /// POST /sessions/{id}/open
  Future<void> openSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Opening session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionOpenEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info(
          'SessionService: Session opened successfully: $sessionId',
        );
      } else {
        throw Exception('Failed to open session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to open session');
      throw Exception(errorMessage ?? 'Failed to open session.');
    }
  }

  /// Pause a session (admin only)
  /// POST /sessions/{id}/pause
  Future<void> pauseSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Pausing session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionPauseEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info(
          'SessionService: Session paused successfully: $sessionId',
        );
      } else {
        throw Exception('Failed to pause session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to pause session');
      throw Exception(errorMessage ?? 'Failed to pause session.');
    }
  }

  /// Close a session (admin only)
  /// POST /sessions/{id}/close
  Future<void> closeSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Closing session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionCloseEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info(
          'SessionService: Session closed successfully: $sessionId',
        );
      } else {
        throw Exception('Failed to close session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to close session');
      throw Exception(errorMessage ?? 'Failed to close session.');
    }
  }

  /// Archive a session (admin only)
  /// POST /sessions/{id}/archive
  Future<void> archiveSession(String sessionId) async {
    try {
      AppLogger.info('SessionService: Archiving session: $sessionId');

      final response = await _apiService.post(
        ApiConstants.sessionArchiveEndpoint(sessionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info(
          'SessionService: Session archived successfully: $sessionId',
        );
      } else {
        throw Exception('Failed to archive session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('SessionService: Failed to archive session');
      throw Exception(errorMessage ?? 'Failed to archive session.');
    }
  }

  /// Get live sessions (helper method)
  Future<List<SessionModel>> getLiveSessions() async {
    return getSessions(status: SessionStatus.live);
  }

  /// Get draft sessions (helper method)
  Future<List<SessionModel>> getDraftSessions() async {
    return getSessions(status: SessionStatus.draft);
  }
}
