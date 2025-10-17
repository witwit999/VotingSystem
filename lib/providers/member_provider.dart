import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member_model.dart';
import '../services/mock_data_service.dart';

final memberProvider =
    StateNotifierProvider<MemberNotifier, AsyncValue<List<MemberModel>>>((ref) {
      return MemberNotifier();
    });

class MemberNotifier extends StateNotifier<AsyncValue<List<MemberModel>>> {
  MemberNotifier() : super(const AsyncValue.loading()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final members = MockDataService.getMembers();
      state = AsyncValue.data(members);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> grantMic(String memberId) async {
    state.whenData((members) {
      final updatedMembers =
          members.map((member) {
            if (member.id == memberId) {
              return member.copyWith(hasMic: true);
            }
            // Remove mic from other members
            return member.copyWith(hasMic: false);
          }).toList();
      state = AsyncValue.data(updatedMembers);
    });
  }

  Future<void> revokeMic(String memberId) async {
    state.whenData((members) {
      final updatedMembers =
          members.map((member) {
            if (member.id == memberId) {
              return member.copyWith(hasMic: false);
            }
            return member;
          }).toList();
      state = AsyncValue.data(updatedMembers);
    });
  }

  Future<void> updateMemberStatus(String memberId, String status) async {
    state.whenData((members) {
      final updatedMembers =
          members.map((member) {
            if (member.id == memberId) {
              return member.copyWith(status: status);
            }
            return member;
          }).toList();
      state = AsyncValue.data(updatedMembers);
    });
  }

  Future<void> refresh() async {
    await loadMembers();
  }
}

// Provider for present members count
final presentMembersCountProvider = Provider<int>((ref) {
  final memberState = ref.watch(memberProvider);
  return memberState.maybeWhen(
    data: (members) => members.where((m) => m.status == 'present').length,
    orElse: () => 0,
  );
});
