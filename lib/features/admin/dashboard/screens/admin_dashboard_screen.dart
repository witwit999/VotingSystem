import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../providers/member_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/voting_provider.dart';
import '../../../../providers/attendance_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberProvider);
    final sessionState = ref.watch(sessionProvider);
    final votingState = ref.watch(currentVotingProvider);
    final attendanceStats = ref.watch(attendanceStatsProvider);
    final l10n = AppLocalizations.of(context);

    final totalMembers = memberState.maybeWhen(
      data: (members) => members.length,
      orElse: () => 0,
    );

    final presentMembers = memberState.maybeWhen(
      data: (members) => members.where((m) => m.status == 'present').length,
      orElse: () => 0,
    );

    final absentMembers = totalMembers - presentMembers;

    final activeSessions = sessionState.maybeWhen(
      data: (sessions) => sessions.where((s) => s.isActive).length,
      orElse: () => 0,
    );

    final totalSessions = sessionState.maybeWhen(
      data: (sessions) => sessions.length,
      orElse: () => 1,
    );

    final currentVoting = votingState.maybeWhen(
      data: (voting) => voting,
      orElse: () => null,
    );

    final attendanceRate = attendanceStats['percentage'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          l10n.adminDashboard,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(memberProvider.notifier).refresh(),
            ref.read(sessionProvider.notifier).refresh(),
            ref.read(currentVotingProvider.notifier).refresh(),
            ref.read(attendanceProvider.notifier).refresh(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              FadeInDown(
                child: Text(
                  l10n.welcomeBackAdmin,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  l10n.heresWhatsHappening,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Stats Charts
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
                children: [
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: _buildMembersChart(
                      context,
                      l10n,
                      totalMembers,
                      presentMembers,
                      absentMembers,
                      onTap: () => context.go('/admin/members'),
                    ),
                  ),
                  FadeInRight(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSessionsChart(
                      context,
                      l10n,
                      activeSessions,
                      totalSessions,
                      onTap: () => context.go('/admin/sessions'),
                    ),
                  ),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: _buildVotingChart(
                      context,
                      l10n,
                      currentVoting,
                      onTap: () => context.go('/admin/voting-control'),
                    ),
                  ),
                  FadeInRight(
                    delay: const Duration(milliseconds: 300),
                    child: _buildAttendanceChart(
                      context,
                      l10n,
                      attendanceRate.toDouble(),
                      onTap: () => context.go('/admin/attendance'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quick Actions
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  l10n.quickActions,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildQuickActionCard(
                  context,
                  icon: Icons.play_circle_filled,
                  title: l10n.startVotingSession,
                  subtitle: l10n.beginNewVotingSession,
                  color: AppColors.primary,
                  onTap: () => context.go('/admin/voting-control'),
                ),
              ),
              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _buildQuickActionCard(
                  context,
                  icon: Icons.add_circle,
                  title: l10n.createNewSession,
                  subtitle: l10n.scheduleNewSession,
                  color: AppColors.info,
                  onTap: () => context.go('/admin/sessions'),
                ),
              ),
              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: _buildQuickActionCard(
                  context,
                  icon: Icons.upload_file,
                  title: l10n.uploadDocumentAction,
                  subtitle: l10n.addMeetingMaterials,
                  color: AppColors.warning,
                  onTap: () => context.go('/admin/documents'),
                ),
              ),
              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: _buildQuickActionCard(
                  context,
                  icon: Icons.bar_chart,
                  title: l10n.viewReports,
                  subtitle: l10n.checkAttendanceReports,
                  color: AppColors.success,
                  onTap: () => context.go('/admin/reports'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersChart(
    BuildContext context,
    AppLocalizations l10n,
    int total,
    int present,
    int absent, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
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
                right: -20,
                top: -20,
                child: Icon(
                  Icons.people,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.totalMembers,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          total > 0
                              ? PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 35,
                                  sections: [
                                    PieChartSectionData(
                                      value: present.toDouble(),
                                      title: present.toString(),
                                      color: Colors.white,
                                      radius: 35,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: absent.toDouble(),
                                      title: absent.toString(),
                                      color: Colors.white.withOpacity(0.3),
                                      radius: 30,
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const Center(
                                child: Icon(
                                  Icons.people_outline,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(l10n.present, present, Colors.white),
                        _buildLegendItem(
                          l10n.absent,
                          absent,
                          Colors.white.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsChart(
    BuildContext context,
    AppLocalizations l10n,
    int active,
    int total, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.info, Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.event,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.activeSessions,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      active.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of $total ${l10n.sessions}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: total.toDouble() + 2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: active.toDouble(),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.5),
                                      Colors.white,
                                    ],
                                  ),
                                  width: 40,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: (total - active).toDouble(),
                                  color: Colors.white.withOpacity(0.2),
                                  width: 40,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotingChart(
    BuildContext context,
    AppLocalizations l10n,
    dynamic voting, {
    required VoidCallback onTap,
  }) {
    final yes = voting?.results.yes ?? 0;
    final no = voting?.results.no ?? 0;
    final abstain = voting?.results.abstain ?? 0;
    final total = voting?.results.total ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.warning, Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                left: -30,
                bottom: -30,
                child: Icon(
                  Icons.how_to_vote,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
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
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.currentVotes,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          total > 0
                              ? PieChart(
                                PieChartData(
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 0,
                                  sections: [
                                    PieChartSectionData(
                                      value: yes.toDouble(),
                                      title: '$yes',
                                      color: Colors.white,
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: no.toDouble(),
                                      title: '$no',
                                      color: Colors.white.withOpacity(0.5),
                                      radius: 55,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: abstain.toDouble(),
                                      title: '$abstain',
                                      color: Colors.white.withOpacity(0.2),
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.ballot_outlined,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.noActiveVoting,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(l10n.yes, yes, Colors.white),
                          _buildLegendItem(
                            l10n.no,
                            no,
                            Colors.white.withOpacity(0.5),
                          ),
                          _buildLegendItem(
                            l10n.abstain,
                            abstain,
                            Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(
    BuildContext context,
    AppLocalizations l10n,
    double percentage, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.success, Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.check_circle,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.attendanceRate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: percentage / 100,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${percentage.toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    l10n.present,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
