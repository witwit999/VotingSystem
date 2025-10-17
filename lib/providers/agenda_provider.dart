import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agenda_model.dart';
import '../services/mock_data_service.dart';

final agendaProvider =
    StateNotifierProvider<AgendaNotifier, AsyncValue<List<AgendaModel>>>((ref) {
      return AgendaNotifier();
    });

class AgendaNotifier extends StateNotifier<AsyncValue<List<AgendaModel>>> {
  AgendaNotifier() : super(const AsyncValue.loading()) {
    loadAgenda();
  }

  Future<void> loadAgenda() async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final agenda = MockDataService.getAgendaItems();
      state = AsyncValue.data(agenda);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAttendance(String agendaId) async {
    state.whenData((agenda) {
      final updatedAgenda =
          agenda.map((item) {
            if (item.id == agendaId) {
              return item.copyWith(hasAttended: true);
            }
            return item;
          }).toList();
      state = AsyncValue.data(updatedAgenda);
    });
  }

  Future<void> refresh() async {
    await loadAgenda();
  }
}

// Provider for filtered agenda items
final upcomingAgendaProvider = Provider<List<AgendaModel>>((ref) {
  final agendaState = ref.watch(agendaProvider);
  return agendaState.maybeWhen(
    data:
        (agenda) => agenda.where((item) => item.status == 'upcoming').toList(),
    orElse: () => [],
  );
});

final ongoingAgendaProvider = Provider<List<AgendaModel>>((ref) {
  final agendaState = ref.watch(agendaProvider);
  return agendaState.maybeWhen(
    data: (agenda) => agenda.where((item) => item.status == 'ongoing').toList(),
    orElse: () => [],
  );
});

final completedAgendaProvider = Provider<List<AgendaModel>>((ref) {
  final agendaState = ref.watch(agendaProvider);
  return agendaState.maybeWhen(
    data:
        (agenda) => agenda.where((item) => item.status == 'completed').toList(),
    orElse: () => [],
  );
});
