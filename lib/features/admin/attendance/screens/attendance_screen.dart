import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/attendance_provider.dart';
import '../../../../models/attendance_model.dart';
import '../../../../core/localization/app_localizations.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final attendanceStats = ref.watch(attendanceStatsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.attendanceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportFeatureComingSoon)),
              );
            },
            tooltip: l10n.export,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/attendance'),
      body: Column(
        children: [
          // Stats Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStatCard(
                      l10n.present,
                      attendanceStats['present'].toString(),
                      const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.success, Color(0xFF2E7D32)],
                      ),
                      Icons.check_circle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildStatCard(
                      l10n.absent,
                      attendanceStats['absent'].toString(),
                      const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.error, Color(0xFFC62828)],
                      ),
                      Icons.cancel,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FadeInRight(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStatCard(
                      l10n.rate,
                      '${attendanceStats['percentage']}%',
                      const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFF1565C0)],
                      ),
                      Icons.pie_chart,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: attendanceState.when(
              data: (attendance) {
                if (attendance.isEmpty) {
                  return FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildEmptyState(l10n),
                  );
                }

                return RefreshIndicator(
                  onRefresh:
                      () => ref.read(attendanceProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: attendance.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 300 + (index * 50)),
                        child: _buildAttendanceItem(
                          context,
                          attendance[index],
                          index,
                        ),
                      );
                    },
                  ),
                );
              },
              loading:
                  () => LoadingIndicator(message: l10n.loadingAttendanceData),
              error:
                  (error, _) => CustomErrorWidget(
                    message: error.toString(),
                    onRetry:
                        () => ref.read(attendanceProvider.notifier).refresh(),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    LinearGradient gradient,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
    BuildContext context,
    AttendanceModel attendance,
    int index,
  ) {
    final l10n = AppLocalizations.of(context);
    final isPresent = attendance.status == 'present';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isPresent
                  ? [AppColors.success, const Color(0xFF2E7D32)]
                  : [AppColors.error.withOpacity(0.8), const Color(0xFFC62828)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPresent ? AppColors.success : AppColors.error)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar with icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isPresent ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Member info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.memberName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${l10n.seat} ${attendance.seatNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              attendance.checkInTime != null
                                  ? DateFormat(
                                    'HH:mm',
                                  ).format(attendance.checkInTime!)
                                  : l10n.notCheckedIn,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      attendance.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(24),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noAttendanceData,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
