import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/message_model.dart';
import '../../../../core/localization/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);

    final currentUserId = authState.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );

    final currentUserName = authState.maybeWhen(
      data: (user) => user?.name,
      orElse: () => 'Unknown',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.groupChat),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(child: Text(l10n.noMessagesYet));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isCurrentUser);
                  },
                );
              },
              loading: () => LoadingIndicator(message: l10n.loadingMessages),
              error:
                  (error, _) => CustomErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref.read(chatProvider.notifier).refresh(),
                  ),
            ),
          ),

          // Message Input
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.typeAMessage,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed:
                        () => _sendMessage(currentUserId, currentUserName),
                    icon: const Icon(Icons.send, color: AppColors.textLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  void _sendMessage(String? userId, String? userName) {
    if (_messageController.text.trim().isEmpty ||
        userId == null ||
        userName == null) {
      return;
    }

    ref
        .read(chatProvider.notifier)
        .sendMessage(userId, userName, _messageController.text.trim());

    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Widget _buildMessageBubble(MessageModel message, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCurrentUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          isCurrentUser
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                  child: Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
