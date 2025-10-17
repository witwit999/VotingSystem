import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../services/mock_data_service.dart';

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<List<SessionModel>>>((
      ref,
    ) {
      return SessionNotifier();
    });

class SessionNotifier extends StateNotifier<AsyncValue<List<SessionModel>>> {
  SessionNotifier() : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final sessions = MockDataService.getSessions();
      state = AsyncValue.data(sessions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createSession(SessionModel session) async {
    state.whenData((sessions) {
      final updatedSessions = [...sessions, session];
      state = AsyncValue.data(updatedSessions);
    });
  }

  Future<void> updateSession(SessionModel session) async {
    state.whenData((sessions) {
      final updatedSessions =
          sessions.map((s) {
            if (s.id == session.id) {
              return session;
            }
            return s;
          }).toList();
      state = AsyncValue.data(updatedSessions);
    });
  }

  Future<void> deleteSession(String sessionId) async {
    state.whenData((sessions) {
      final updatedSessions = sessions.where((s) => s.id != sessionId).toList();
      state = AsyncValue.data(updatedSessions);
    });
  }

  Future<void> refresh() async {
    await loadSessions();
  }
}

// Provider for active session
final activeSessionProvider = Provider<SessionModel?>((ref) {
  final sessionState = ref.watch(sessionProvider);
  return sessionState.maybeWhen(
    data:
        (sessions) => sessions.firstWhere(
          (s) => s.isActive,
          orElse: () => sessions.first,
        ),
    orElse: () => null,
  );
});
