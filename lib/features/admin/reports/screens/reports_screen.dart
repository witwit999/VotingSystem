import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../providers/voting_provider.dart';
import '../../../../providers/attendance_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votingHistory = ref.watch(votingHistoryProvider);
    final attendanceStats = ref.watch(attendanceStatsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.exportPdfComingSoon)));
            },
            tooltip: l10n.exportPdf,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Report
            FadeInDown(
              child: Text(
                l10n.attendanceOverview,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildAttendanceCard(attendanceStats, l10n),
            ),

            const SizedBox(height: 40),

            // Voting Reports
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Text(
                l10n.votingHistory,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            votingHistory.when(
              data: (history) {
                if (history.isEmpty) {
                  return FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildEmptyState(l10n),
                  );
                }

                return Column(
                  children: List.generate(history.length, (index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: 400 + (index * 100)),
                      child: _buildVotingCard(history[index], index, l10n),
                    );
                  }),
                );
              },
              loading:
                  () => FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(60),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.info.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error:
                  (error, _) => FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.error, Color(0xFFC62828)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${l10n.error}: $error',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(
    Map<String, dynamic> stats,
    AppLocalizations l10n,
  ) {
    final total = stats['total'] ?? 0;
    final present = stats['present'] ?? 0;
    final absent = stats['absent'] ?? 0;
    final percentage = stats['percentage'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.attendanceOverview,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        l10n.total,
                        total.toString(),
                        Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        l10n.present,
                        present.toString(),
                        Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        l10n.absent,
                        absent.toString(),
                        Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Chart
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: present.toDouble(),
                                  title: '$percentage%',
                                  color: Colors.white,
                                  radius: 90,
                                  titleStyle: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: absent.toDouble(),
                                  title: '${100 - percentage}%',
                                  color: Colors.white.withOpacity(0.3),
                                  radius: 85,
                                  titleStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                              sectionsSpace: 3,
                              centerSpaceRadius: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                l10n.present,
                                '$percentage%',
                                Colors.white,
                              ),
                              const SizedBox(height: 20),
                              _buildLegendItem(
                                l10n.absent,
                                '${100 - percentage}%',
                                Colors.white.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingCard(dynamic voting, int index, AppLocalizations l10n) {
    // Gradient colors based on index
    final gradients = [
      [AppColors.primary, const Color(0xFF1565C0)],
      [AppColors.warning, const Color(0xFFF57C00)],
      [AppColors.info, const Color(0xFF1976D2)],
      [const Color(0xFF7E57C2), const Color(0xFF5E35B1)],
    ];

    final gradientIndex = index % gradients.length;
    final colors = gradients[gradientIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.poll_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.how_to_vote,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          voting.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Voting results
                  Row(
                    children: [
                      Expanded(
                        child: _buildVoteColumn(
                          l10n.yes.toUpperCase(),
                          voting.results.yes,
                          voting.results.yesPercentage,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildVoteColumn(
                          l10n.no.toUpperCase(),
                          voting.results.no,
                          voting.results.noPercentage,
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildVoteColumn(
                          l10n.abstain.toUpperCase(),
                          voting.results.abstain,
                          voting.results.abstainPercentage,
                          Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Chart visualization
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: [
                          if (voting.results.yes > 0)
                            Expanded(
                              flex: voting.results.yes,
                              child: Container(color: Colors.white),
                            ),
                          if (voting.results.no > 0)
                            Expanded(
                              flex: voting.results.no,
                              child: Container(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          if (voting.results.abstain > 0)
                            Expanded(
                              flex: voting.results.abstain,
                              child: Container(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${l10n.totalVotes}: ${voting.results.total}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteColumn(
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.textSecondary.withOpacity(0.1),
            AppColors.textSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 2),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noVotingHistoryAvailable,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
