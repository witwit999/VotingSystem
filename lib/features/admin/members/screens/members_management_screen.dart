import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/member_provider.dart';
import '../../../../models/member_model.dart';
import '../../../../core/localization/app_localizations.dart';

class MembersManagementScreen extends ConsumerStatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  ConsumerState<MembersManagementScreen> createState() =>
      _MembersManagementScreenState();
}

class _MembersManagementScreenState
    extends ConsumerState<MembersManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(memberProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.membersManagement),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchMembers,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/members'),
      body: memberState.when(
        data: (members) {
          final filteredMembers =
              _searchQuery.isEmpty
                  ? members
                  : members
                      .where(
                        (m) => m.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();

          if (filteredMembers.isEmpty) {
            return Center(child: Text(l10n.noMembersFound));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(memberProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                return _buildMemberCard(context, ref, filteredMembers[index]);
              },
            ),
          );
        },
        loading: () => LoadingIndicator(message: l10n.loadingMembers),
        error:
            (error, _) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(memberProvider.notifier).refresh(),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.addMemberComingSoon)));
        },
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addMember),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    WidgetRef ref,
    MemberModel member,
  ) {
    final statusColor =
        member.status == 'present'
            ? AppColors.statusPresent
            : AppColors.statusAbsent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                member.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).seat}: ${member.seatNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (member.hasMic) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.mic,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                final l10n = AppLocalizations.of(context);
                if (value == 'grant_mic') {
                  ref.read(memberProvider.notifier).grantMic(member.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.microphoneGrantedTo} ${member.name}',
                      ),
                    ),
                  );
                } else if (value == 'revoke_mic') {
                  ref.read(memberProvider.notifier).revokeMic(member.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.microphoneRevokedFrom} ${member.name}',
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                final l10n = AppLocalizations.of(context);
                return [
                  PopupMenuItem(
                    value: member.hasMic ? 'revoke_mic' : 'grant_mic',
                    child: Row(
                      children: [
                        Icon(
                          member.hasMic ? Icons.mic_off : Icons.mic,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(member.hasMic ? l10n.revokeMic : l10n.grantMic),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
