import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/decision_model.dart';
import '../services/decision_service.dart';
import '../core/utils/app_logger.dart';
import 'auth_provider.dart';

// Decision Service Provider
final decisionServiceProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return DecisionService(apiService);
});

// Session Decisions Provider - decisions for a specific session
final sessionDecisionsProvider = StateNotifierProvider.family<
  SessionDecisionsNotifier,
  AsyncValue<List<DecisionModel>>,
  String
>((ref, sessionId) {
  return SessionDecisionsNotifier(ref.read(decisionServiceProvider), sessionId);
});

class SessionDecisionsNotifier
    extends StateNotifier<AsyncValue<List<DecisionModel>>> {
  final DecisionService _decisionService;
  final String sessionId;

  SessionDecisionsNotifier(this._decisionService, this.sessionId)
    : super(const AsyncValue.loading()) {
    AppLogger.info(
      'SessionDecisionsNotifier: Initializing for session: $sessionId',
    );
    loadDecisions();
  }

  /// Load decisions for the session
  Future<void> loadDecisions() async {
    state = const AsyncValue.loading();
    try {
      final decisions = await _decisionService.getSessionDecisions(sessionId);
      state = AsyncValue.data(decisions);
      AppLogger.info(
        'SessionDecisionsNotifier: Loaded ${decisions.length} decisions',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionDecisionsNotifier: Failed to load decisions',
        e,
        stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Create a new decision
  Future<void> createDecision({
    required String title,
    String? description,
    bool allowRecast = false,
  }) async {
    try {
      AppLogger.info('SessionDecisionsNotifier: Creating decision: $title');

      await _decisionService.createDecision(
        sessionId: sessionId,
        title: title,
        description: description,
        allowRecast: allowRecast,
      );

      await loadDecisions(); // Refresh list
      AppLogger.info('SessionDecisionsNotifier: Decision created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionDecisionsNotifier: Failed to create decision',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Open a decision for voting
  Future<void> openDecision(String decisionId, DateTime closeAt) async {
    try {
      AppLogger.info('SessionDecisionsNotifier: Opening decision: $decisionId');

      await _decisionService.openDecision(decisionId, closeAt);
      await loadDecisions(); // Refresh to get updated status

      AppLogger.info('SessionDecisionsNotifier: Decision opened successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionDecisionsNotifier: Failed to open decision',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Close a decision
  Future<void> closeDecision(String decisionId) async {
    try {
      AppLogger.info('SessionDecisionsNotifier: Closing decision: $decisionId');

      await _decisionService.closeDecision(decisionId);
      await loadDecisions(); // Refresh to get final tally

      AppLogger.info('SessionDecisionsNotifier: Decision closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionDecisionsNotifier: Failed to close decision',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Submit a vote
  Future<void> submitVote(String decisionId, VoteChoice choice) async {
    try {
      AppLogger.info(
        'SessionDecisionsNotifier: Submitting vote: ${choice.value}',
      );

      await _decisionService.submitVote(decisionId: decisionId, choice: choice);

      await loadDecisions(); // Refresh to get updated tally
      AppLogger.info('SessionDecisionsNotifier: Vote submitted successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SessionDecisionsNotifier: Failed to submit vote',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh decisions
  Future<void> refresh() async {
    await loadDecisions();
  }
}

// Provider for open decisions in a session
final openDecisionsProvider = Provider.family<List<DecisionModel>, String>((
  ref,
  sessionId,
) {
  final decisionsState = ref.watch(sessionDecisionsProvider(sessionId));
  return decisionsState.maybeWhen(
    data: (decisions) => decisions.where((d) => d.isOpen).toList(),
    orElse: () => [],
  );
});

// Provider for current active decision (first open decision)
final activeDecisionProvider = Provider.family<DecisionModel?, String>((
  ref,
  sessionId,
) {
  final openDecisions = ref.watch(openDecisionsProvider(sessionId));
  return openDecisions.isNotEmpty ? openDecisions.first : null;
});
