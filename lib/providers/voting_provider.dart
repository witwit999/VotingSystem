import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/decision_model.dart';
import '../providers/decision_provider.dart';
import '../providers/session_provider.dart';
import '../core/utils/app_logger.dart';

/// Provider for the current active voting session/decision
/// This finds the first open decision across all live sessions
final currentVotingProvider =
    StateNotifierProvider<CurrentVotingNotifier, AsyncValue<DecisionModel?>>((
      ref,
    ) {
      return CurrentVotingNotifier(ref);
    });

class CurrentVotingNotifier extends StateNotifier<AsyncValue<DecisionModel?>> {
  final Ref _ref;

  // Don't load automatically in constructor to avoid modifying other providers during initialization
  CurrentVotingNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> loadCurrentVoting() async {
    state = const AsyncValue.loading();
    try {
      AppLogger.info('CurrentVotingNotifier: Loading current voting session');

      // Load live sessions first
      await _ref.read(sessionProvider.notifier).loadLiveSessions();

      final sessions = _ref.read(liveSessionsProvider);

      if (sessions.isEmpty) {
        AppLogger.info('CurrentVotingNotifier: No live sessions found');
        state = const AsyncValue.data(null);
        return;
      }

      // Find the first session with an open decision
      for (final session in sessions) {
        // Load decisions for this session first
        await _ref
            .read(sessionDecisionsProvider(session.id).notifier)
            .loadDecisions();

        final decisionsState = _ref.read(sessionDecisionsProvider(session.id));

        decisionsState.when(
          data: (decisions) {
            final openDecisions =
                decisions
                    .where((d) => d.status == DecisionStatus.open)
                    .toList();

            if (openDecisions.isNotEmpty) {
              AppLogger.info(
                'CurrentVotingNotifier: Found open decision: ${openDecisions.first.title}',
              );
              state = AsyncValue.data(openDecisions.first);
            }
          },
          loading: () {},
          error: (e, _) {
            AppLogger.error(
              'CurrentVotingNotifier: Error loading decisions for session ${session.id}',
              e,
            );
          },
        );

        // If we found an open decision, stop searching
        if (state.value != null) break;
      }

      // If no open decisions found
      if (state.value == null) {
        AppLogger.info('CurrentVotingNotifier: No open decisions found');
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      AppLogger.error('CurrentVotingNotifier: Unexpected error', e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadCurrentVoting();
  }
}

/// Provider for voting history (closed decisions across all sessions)
/// Note: This returns a simplified list and may not be as real-time as watching individual sessions
final votingHistoryProvider = Provider<List<DecisionModel>>((ref) {
  AppLogger.info('VotingHistoryProvider: Loading voting history');

  try {
    final sessions = ref.watch(liveSessionsProvider);
    final allDecisions = <DecisionModel>[];

    // Load decisions from all sessions
    for (final session in sessions) {
      final decisionsState = ref.watch(sessionDecisionsProvider(session.id));

      decisionsState.whenData((decisions) {
        // Only include closed decisions
        final closedDecisions =
            decisions.where((d) => d.status == DecisionStatus.closed).toList();
        allDecisions.addAll(closedDecisions);
      });
    }

    // Sort by close date (most recent first)
    allDecisions.sort((a, b) {
      if (a.closeAt == null && b.closeAt == null) return 0;
      if (a.closeAt == null) return 1;
      if (b.closeAt == null) return -1;
      return b.closeAt!.compareTo(a.closeAt!);
    });

    AppLogger.info(
      'VotingHistoryProvider: Loaded ${allDecisions.length} historical decisions',
    );
    return allDecisions;
  } catch (e) {
    AppLogger.error('VotingHistoryProvider: Unexpected error', e);
    return <DecisionModel>[];
  }
});
