import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/voting_provider.dart';
import '../../../../models/decision_model.dart';
import '../../../../core/localization/app_localizations.dart';

class VotingControlScreen extends ConsumerStatefulWidget {
  const VotingControlScreen({super.key});

  @override
  ConsumerState<VotingControlScreen> createState() =>
      _VotingControlScreenState();
}

class _VotingControlScreenState extends ConsumerState<VotingControlScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger load after frame is built to avoid initialization issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentVotingProvider.notifier).loadCurrentVoting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final votingState = ref.watch(currentVotingProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.votingControl_title),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/voting-control'),
      body: votingState.when(
        data: (decision) {
          return RefreshIndicator(
            onRefresh: () => ref.read(currentVotingProvider.notifier).refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Control Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FadeInLeft(
                          delay: const Duration(milliseconds: 100),
                          child: _buildControlButton(
                            context,
                            icon: Icons.play_arrow,
                            label: l10n.startVoting,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.success, Color(0xFF2E7D32)],
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.createVotingSessionComingSoon,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FadeInRight(
                          delay: const Duration(milliseconds: 100),
                          child: _buildControlButton(
                            context,
                            icon: Icons.stop,
                            label: l10n.endVoting,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.error, Color(0xFFC62828)],
                            ),
                            onPressed:
                                decision?.isOpen == true
                                    ? () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.featureComingSoon),
                                        ),
                                      );
                                    }
                                    : null,
                            isEnabled: decision?.isOpen == true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (decision != null && decision.isOpen) ...[
                    // Current Voting Session
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildCurrentVotingCard(context, decision, l10n),
                    ),

                    const SizedBox(height: 32),

                    // Live Results
                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        l10n.liveResults,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildLiveResultsCard(context, decision, l10n),
                    ),
                  ] else ...[
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildEmptyState(context, l10n),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => LoadingIndicator(message: l10n.loadingVotingData),
        error:
            (error, _) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(currentVotingProvider.notifier).refresh(),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.createVotingSessionComingSoon)),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newVoting),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient:
              isEnabled
                  ? gradient
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.textSecondary.withOpacity(0.5),
                      AppColors.textSecondary.withOpacity(0.3),
                    ],
                  ),
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isEnabled
                  ? [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentVotingCard(
    BuildContext context,
    DecisionModel decision,
    AppLocalizations l10n,
  ) {
    final total =
        decision.tally != null
            ? decision.tally!.accepted +
                decision.tally!.denied +
                decision.tally!.abstained
            : 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.how_to_vote,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.poll,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.currentVotingSession,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.active.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    decision.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (decision.description != null &&
                      decision.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      decision.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.totalVotes}: $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildLiveResultsCard(
    BuildContext context,
    DecisionModel decision,
    AppLocalizations l10n,
  ) {
    // If no tally, show placeholder
    if (decision.tally == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.warning, Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            'No votes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final tally = decision.tally!;
    final total = tally.accepted + tally.denied + tally.abstained;
    final maxY = total > 0 ? total.toDouble() * 1.2 : 10.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warning, Color(0xFFF57C00)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              left: -40,
              bottom: -40,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVoteCountCard(
                        l10n.accepted.toUpperCase(),
                        tally.accepted,
                        tally.acceptPercentage,
                      ),
                      _buildVoteCountCard(
                        l10n.denied.toUpperCase(),
                        tally.denied,
                        tally.denyPercentage,
                      ),
                      _buildVoteCountCard(
                        l10n.abstain.toUpperCase(),
                        tally.abstained,
                        tally.abstainPercentage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxY,
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: tally.accepted.toDouble(),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.white, Colors.white],
                                ),
                                width: 50,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: tally.denied.toDouble(),
                                color: Colors.white.withOpacity(0.7),
                                width: 50,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: tally.abstained.toDouble(),
                                color: Colors.white.withOpacity(0.4),
                                width: 50,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = [
                                  l10n.accepted.toUpperCase(),
                                  l10n.denied.toUpperCase(),
                                  l10n.abstain.toUpperCase(),
                                ];
                                final index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
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
    );
  }

  Widget _buildVoteCountCard(String label, int count, double percentage) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noActiveVotingSession,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.startNewVotingSession,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
