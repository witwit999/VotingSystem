import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../core/utils/app_logger.dart';
import 'auth_provider.dart'; // Import to get apiServiceProvider

// Session Service Provider
final sessionServiceProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SessionService(apiService);
});

// Session State Provider
final sessionProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<List<SessionModel>>>((
      ref,
    ) {
      return SessionNotifier(ref.read(sessionServiceProvider));
    });

class SessionNotifier extends StateNotifier<AsyncValue<List<SessionModel>>> {
  final SessionService _sessionService;
  SessionStatus? _currentFilter;

  SessionNotifier(this._sessionService) : super(const AsyncValue.data([])) {
    AppLogger.info(
      'SessionNotifier: Initialized (sessions will load when needed)',
    );
    // Don't auto-load sessions on init - wait for screen to request them
  }

  /// Load sessions from backend with optional status filter
  Future<void> loadSessions({SessionStatus? status}) async {
    state = const AsyncValue.loading();
    try {
      _currentFilter = status;
      final sessions = await _sessionService.getSessions(status: status);
      state = AsyncValue.data(sessions);
      AppLogger.info(
        'SessionNotifier: Sessions loaded successfully (${sessions.length} sessions)',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to load sessions',
        e,
        stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Get live sessions only
  Future<void> loadLiveSessions() async {
    await loadSessions(status: SessionStatus.live);
  }

  /// Get draft sessions only
  Future<void> loadDraftSessions() async {
    await loadSessions(status: SessionStatus.draft);
  }

  /// Join a session
  Future<void> joinSession(String sessionId) async {
    try {
      AppLogger.info('SessionNotifier: Attempting to join session: $sessionId');
      await _sessionService.joinSession(sessionId);

      // Refresh session details after joining
      await refresh();
      AppLogger.info('SessionNotifier: Successfully joined session');
    } catch (e, stackTrace) {
      AppLogger.error('SessionNotifier: Failed to join session', e, stackTrace);
      rethrow;
    }
  }

  /// Leave a session
  Future<void> leaveSession(String sessionId) async {
    try {
      AppLogger.info(
        'SessionNotifier: Attempting to leave session: $sessionId',
      );
      await _sessionService.leaveSession(sessionId);

      // Refresh session details after leaving
      await refresh();
      AppLogger.info('SessionNotifier: Successfully left session');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to leave session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Create a new session (admin only)
  Future<void> createSession(String name) async {
    try {
      AppLogger.info('SessionNotifier: Creating new session: $name');
      await _sessionService.createSession(name);

      // Load ALL sessions after creation (not just filtered ones)
      // because newly created sessions are DRAFT by default
      await loadSessions();
      AppLogger.info('SessionNotifier: Session created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to create session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Open a session (admin only)
  Future<void> openSession(String sessionId) async {
    try {
      AppLogger.info('SessionNotifier: Opening session: $sessionId');
      await _sessionService.openSession(sessionId);
      await refresh();
      AppLogger.info('SessionNotifier: Session opened successfully');
    } catch (e, stackTrace) {
      AppLogger.error('SessionNotifier: Failed to open session', e, stackTrace);
      rethrow;
    }
  }

  /// Pause a session (admin only)
  Future<void> pauseSession(String sessionId) async {
    try {
      AppLogger.info('SessionNotifier: Pausing session: $sessionId');
      await _sessionService.pauseSession(sessionId);
      await refresh();
      AppLogger.info('SessionNotifier: Session paused successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to pause session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Close a session (admin only)
  Future<void> closeSession(String sessionId) async {
    try {
      AppLogger.info('SessionNotifier: Closing session: $sessionId');
      await _sessionService.closeSession(sessionId);
      await refresh();
      AppLogger.info('SessionNotifier: Session closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to close session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Archive a session (admin only)
  Future<void> archiveSession(String sessionId) async {
    try {
      AppLogger.info('SessionNotifier: Archiving session: $sessionId');
      await _sessionService.archiveSession(sessionId);
      await refresh();
      AppLogger.info('SessionNotifier: Session archived successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionNotifier: Failed to archive session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh sessions list
  Future<void> refresh() async {
    await loadSessions(status: _currentFilter);
  }
}

// Provider for live sessions only
final liveSessionsProvider = Provider<List<SessionModel>>((ref) {
  final sessionState = ref.watch(sessionProvider);
  return sessionState.maybeWhen(
    data: (sessions) => sessions.where((s) => s.isLive).toList(),
    orElse: () => [],
  );
});

// Provider for active (live) session
final activeSessionProvider = Provider<SessionModel?>((ref) {
  final liveSessions = ref.watch(liveSessionsProvider);
  return liveSessions.isNotEmpty ? liveSessions.first : null;
});
