import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voting_model.dart';
import '../services/mock_data_service.dart';

final currentVotingProvider =
    StateNotifierProvider<VotingNotifier, AsyncValue<VotingModel?>>((ref) {
      return VotingNotifier();
    });

class VotingNotifier extends StateNotifier<AsyncValue<VotingModel?>> {
  VotingNotifier() : super(const AsyncValue.loading()) {
    loadCurrentVoting();
  }

  Future<void> loadCurrentVoting() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final voting = MockDataService.getCurrentVoting();
      state = AsyncValue.data(voting);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitVote(String vote) async {
    state.whenData((voting) {
      if (voting != null) {
        // Update vote counts
        final results = voting.results;
        int newYes = results.yes;
        int newNo = results.no;
        int newAbstain = results.abstain;

        switch (vote) {
          case 'yes':
            newYes++;
            break;
          case 'no':
            newNo++;
            break;
          case 'abstain':
            newAbstain++;
            break;
        }

        final updatedVoting = voting.copyWith(
          userVote: vote,
          results: VotingResults(
            yes: newYes,
            no: newNo,
            abstain: newAbstain,
            total: results.total + 1,
          ),
        );

        state = AsyncValue.data(updatedVoting);
      }
    });
  }

  Future<void> refresh() async {
    await loadCurrentVoting();
  }
}

final votingHistoryProvider = FutureProvider<List<VotingModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return MockDataService.getVotingHistory();
});
