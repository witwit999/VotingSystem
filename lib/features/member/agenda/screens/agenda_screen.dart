import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/agenda_provider.dart';
import '../../../../models/agenda_model.dart';
import '../../../../core/localization/app_localizations.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final agendaState = ref.watch(agendaProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.agenda),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(l10n.all, 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.ongoing, 'ongoing'),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.upcoming, 'upcoming'),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.completed, 'completed'),
              ],
            ),
          ),

          // Agenda List
          Expanded(
            child: agendaState.when(
              data: (agenda) {
                final filteredAgenda =
                    _selectedFilter == 'all'
                        ? agenda
                        : agenda
                            .where((item) => item.status == _selectedFilter)
                            .toList();

                if (filteredAgenda.isEmpty) {
                  return Center(child: Text(l10n.noAgendaItems));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(agendaProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredAgenda.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildAgendaItem(filteredAgenda[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => LoadingIndicator(message: l10n.loadingAgenda),
              error:
                  (error, _) => CustomErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref.read(agendaProvider.notifier).refresh(),
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.textLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(AgendaModel item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case 'ongoing':
        statusColor = AppColors.success;
        statusIcon = Icons.play_circle_filled;
        break;
      case 'upcoming':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.circle;
    }

    return CustomCard(
      onTap: () => _showAgendaDetails(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                item.speaker,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (item.hasAttended) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).attended,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAgendaDetails(AgendaModel item) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.person,
                          l10n.speaker_label,
                          item.speaker,
                        ),
                        _buildDetailRow(
                          Icons.access_time,
                          l10n.time,
                          '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                        ),
                        _buildDetailRow(
                          Icons.calendar_today,
                          l10n.date,
                          DateFormat(
                            'EEEE, MMM d, yyyy',
                          ).format(item.startTime),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                        if (!item.hasAttended && item.status != 'completed')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(agendaProvider.notifier)
                                    .markAttendance(item.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.attendanceMarked),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle),
                              label: Text(l10n.markAttendance),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
