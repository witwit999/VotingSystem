import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/mock_data_service.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<MessageModel>>>((ref) {
      return ChatNotifier();
    });

class ChatNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  ChatNotifier() : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final messages = MockDataService.getMessages();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(
    String senderId,
    String senderName,
    String text,
  ) async {
    state.whenData((messages) {
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...messages, newMessage];
      state = AsyncValue.data(updatedMessages);
    });
  }

  Future<void> refresh() async {
    await loadMessages();
  }
}
