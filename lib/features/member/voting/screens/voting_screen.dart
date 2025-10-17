import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/decision_provider.dart';
import '../../../../models/decision_model.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';

class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  String? _joinedSessionId;
  final Set<String> _votedDecisions =
      {}; // Track which decisions user has voted on

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveSession();
    });
  }

  Future<void> _loadActiveSession() async {
    AppLogger.info('VotingScreen: Loading active session for member');

    // Get live sessions
    await ref.read(sessionProvider.notifier).loadLiveSessions();

    final sessions = ref.read(liveSessionsProvider);

    if (sessions.isNotEmpty) {
      // For now, get the first live session
      // In a real app, we'd track which session the member joined
      final firstSession = sessions.first;
      if (mounted) {
        setState(() {
          _joinedSessionId = firstSession.id;
        });

        AppLogger.info(
          'VotingScreen: Loading decisions for session: ${firstSession.id}',
        );
        // Load decisions for this session
        await ref
            .read(sessionDecisionsProvider(firstSession.id).notifier)
            .loadDecisions();
      }
    } else {
      AppLogger.warning('VotingScreen: No live sessions available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_joinedSessionId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: l10n.voting),
        body: Center(child: FadeInUp(child: _buildEmptyState(context, l10n))),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      );
    }

    final decisionsState = ref.watch(
      sessionDecisionsProvider(_joinedSessionId!),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.voting),
      body: decisionsState.when(
        data: (decisions) {
          // Find the first OPEN decision
          final openDecisions =
              decisions.where((d) => d.status == DecisionStatus.open).toList();

          if (openDecisions.isEmpty) {
            return Center(
              child: FadeInUp(child: _buildEmptyState(context, l10n)),
            );
          }

          final activeDecision = openDecisions.first;

          // Check if user has voted and recast is not allowed
          final hasVoted = _votedDecisions.contains(activeDecision.id);
          final canVote = !hasVoted || activeDecision.allowRecast;

          return RefreshIndicator(
            onRefresh:
                () =>
                    ref
                        .read(
                          sessionDecisionsProvider(_joinedSessionId!).notifier,
                        )
                        .loadDecisions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card with Title
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildDecisionCard(activeDecision),
                  ),
                  const SizedBox(height: 32),

                  // Voting Buttons
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: _buildVoteButton(
                      context,
                      ref,
                      label: l10n.accepted.toUpperCase(),
                      choice: VoteChoice.accept,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.voteYes, Color(0xFF2E7D32)],
                      ),
                      icon: Icons.thumb_up,
                      decisionId: activeDecision.id,
                      isEnabled: canVote,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInRight(
                    delay: const Duration(milliseconds: 300),
                    child: _buildVoteButton(
                      context,
                      ref,
                      label: l10n.denied.toUpperCase(),
                      choice: VoteChoice.deny,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.voteNo, Color(0xFFC62828)],
                      ),
                      icon: Icons.thumb_down,
                      decisionId: activeDecision.id,
                      isEnabled: canVote,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildVoteButton(
                      context,
                      ref,
                      label: l10n.abstain.toUpperCase(),
                      choice: VoteChoice.abstain,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.voteAbstain, Color(0xFF757575)],
                      ),
                      icon: Icons.remove_circle_outline,
                      decisionId: activeDecision.id,
                      isEnabled: canVote,
                    ),
                  ),

                  // Show "Already Voted" message if voted and can't recast
                  if (hasVoted && !activeDecision.allowRecast) ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.voteSubmittedSuccessfully,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Live Results
                  if (activeDecision.tally != null)
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildLiveResults(activeDecision, l10n),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => LoadingIndicator(message: l10n.loadingVotingSession),
        error:
            (error, _) => CustomErrorWidget(
              message: error.toString(),
              onRetry:
                  () =>
                      ref
                          .read(
                            sessionDecisionsProvider(
                              _joinedSessionId!,
                            ).notifier,
                          )
                          .loadDecisions(),
            ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildDecisionCard(DecisionModel decision) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.poll, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  decision.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (decision.description != null &&
              decision.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                decision.description!,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required VoteChoice choice,
    required LinearGradient gradient,
    required IconData icon,
    required String decisionId,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap:
          isEnabled
              ? () => _showConfirmDialog(
                context,
                ref,
                label,
                choice,
                gradient,
                decisionId,
              )
              : null,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient:
              isEnabled
                  ? gradient
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.textSecondary.withOpacity(0.3),
                      AppColors.textSecondary.withOpacity(0.2),
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
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void _showConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    VoteChoice choice,
    LinearGradient gradient,
    String decisionId,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.confirmYourVote,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to vote "$label"?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _submitVote(
                                ref,
                                decisionId,
                                choice,
                                gradient,
                                l10n,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: gradient.colors.first,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.confirm,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _submitVote(
    WidgetRef ref,
    String decisionId,
    VoteChoice choice,
    LinearGradient gradient,
    AppLocalizations l10n,
  ) async {
    try {
      AppLogger.info(
        'Member: Submitting vote for decision: $decisionId, choice: ${choice.name}',
      );

      await ref
          .read(sessionDecisionsProvider(_joinedSessionId!).notifier)
          .submitVote(decisionId, choice);

      // Mark this decision as voted
      if (mounted) {
        setState(() {
          _votedDecisions.add(decisionId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.voteSubmittedSuccessfully),
            backgroundColor: gradient.colors.first,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Member: Failed to submit vote: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit vote: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildLiveResults(DecisionModel decision, AppLocalizations l10n) {
    final tally = decision.tally!;
    final total = tally.accepted + tally.denied + tally.abstained;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.info, Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.bar_chart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.liveResults,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$total ${l10n.votes}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResultBar(
            l10n.accepted.toUpperCase(),
            tally.accepted,
            tally.acceptPercentage,
          ),
          const SizedBox(height: 16),
          _buildResultBar(
            l10n.denied.toUpperCase(),
            tally.denied,
            tally.denyPercentage,
          ),
          const SizedBox(height: 16),
          _buildResultBar(
            l10n.abstain.toUpperCase(),
            tally.abstained,
            tally.abstainPercentage,
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar(String label, int count, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            l10n.noActiveVotingSession_member,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.pleaseWaitForVoting,
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
