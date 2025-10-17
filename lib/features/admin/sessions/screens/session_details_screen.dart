import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../models/session_model.dart';
import '../../../../models/decision_model.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/decision_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class SessionDetailsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailsScreen> createState() =>
      _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends ConsumerState<SessionDetailsScreen> {
  SessionModel? _sessionDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionDetails();
    // Load decisions after frame is built to avoid provider issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDecisions();
    });
  }

  Future<void> _loadSessionDetails() async {
    try {
      AppLogger.info(
        'SessionDetailsScreen: Loading session details: ${widget.sessionId}',
      );
      final sessionService = ref.read(sessionServiceProvider);
      final session = await sessionService.getSessionDetails(widget.sessionId);

      if (mounted) {
        setState(() {
          _sessionDetails = session;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error(
        'SessionDetailsScreen: Failed to load session details',
        e,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load session: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadDecisions() async {
    // Trigger the sessionDecisionsProvider to load
    AppLogger.info(
      'SessionDetailsScreen: Loading decisions for session: ${widget.sessionId}',
    );
    await ref
        .read(sessionDecisionsProvider(widget.sessionId).notifier)
        .loadDecisions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decisionsState = ref.watch(
      sessionDecisionsProvider(widget.sessionId),
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text(l10n.sessionDetails),
        ),
        body: LoadingIndicator(message: l10n.loadingSessions),
      );
    }

    if (_sessionDetails == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text(l10n.sessionDetails),
        ),
        body: CustomErrorWidget(
          message: 'Session not found',
          onRetry: _loadSessionDetails,
        ),
      );
    }

    final session = _sessionDetails!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(l10n.sessionDetails),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Info Card
            FadeInUp(child: _buildSessionInfoCard(session, l10n)),

            const SizedBox(height: 32),

            // Decisions Section Header
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.ballot,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.decisions,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (session.isLive || session.isPaused)
                    ElevatedButton.icon(
                      onPressed: () => _showCreateDecisionDialog(l10n),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.newDecision),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Decisions List
            decisionsState.when(
              data: (decisions) {
                if (decisions.isEmpty) {
                  return FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.ballot_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No decisions created yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      decisions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final decision = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 200 + (index * 100)),
                          child: _buildDecisionCard(decision, l10n),
                        );
                      }).toList(),
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (error, _) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomErrorWidget(
                      message: error.toString(),
                      onRetry: _loadDecisions,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(SessionModel session, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              session.isLive
                  ? [AppColors.success, const Color(0xFF2E7D32)]
                  : session.isDraft
                  ? [AppColors.warning, const Color(0xFFF57C00)]
                  : [AppColors.primary, const Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  session.status.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        session.isLive ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (session.agendaText != null && session.agendaText!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.agendaText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(session.createdAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard(DecisionModel decision, AppLocalizations l10n) {
    final isOpen = decision.isOpen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? AppColors.success : AppColors.divider,
          width: isOpen ? 2 : 1,
        ),
        boxShadow: [
          if (isOpen)
            BoxShadow(
              color: AppColors.success.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decision.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (decision.description != null &&
                        decision.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        decision.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.success : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      decision.status.value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (decision.tally != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildTallyDisplay(decision.tally!, l10n),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (!isOpen && decision.status == DecisionStatus.closed)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewResultsDialog(decision, l10n),
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: const Text('View Results'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                    ),
                  ),
                ),
              if (isOpen) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCloseDecision(decision.id),
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.closeDecision),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              if (decision.status == DecisionStatus.closed) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showOpenDecisionDialog(decision),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l10n.openDecision),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTallyDisplay(DecisionTally tally, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTallyItem(
          l10n.accepted,
          tally.accepted,
          tally.acceptPercentage,
          AppColors.voteYes,
        ),
        Container(width: 1, height: 40, color: AppColors.divider),
        _buildTallyItem(
          l10n.denied,
          tally.denied,
          tally.denyPercentage,
          AppColors.voteNo,
        ),
        Container(width: 1, height: 40, color: AppColors.divider),
        _buildTallyItem(
          l10n.abstain,
          tally.abstained,
          tally.abstainPercentage,
          AppColors.voteAbstain,
        ),
      ],
    );
  }

  Widget _buildTallyItem(
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  void _showCreateDecisionDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) =>
              _CreateDecisionDialog(sessionId: widget.sessionId, l10n: l10n),
    );
  }

  void _showOpenDecisionDialog(DecisionModel decision) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow, color: AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.openDecision,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decision.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 18, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voting will be open for 5 minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Members will be able to vote immediately',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton.icon(
                onPressed:
                    () => _handleOpenDecisionSimple(decision.id, context),
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.openDecision),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleOpenDecisionSimple(
    String decisionId,
    BuildContext dialogContext,
  ) async {
    // Close dialog
    Navigator.of(dialogContext).pop();

    try {
      // Set closing time to NOW + 5 minutes
      final closeAt = DateTime.now().add(const Duration(minutes: 5));

      AppLogger.info(
        'Admin: Opening decision with 5-minute timer: $decisionId',
      );

      await ref
          .read(sessionDecisionsProvider(widget.sessionId).notifier)
          .openDecision(decisionId, closeAt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Decision opened! Voting ends in 5 minutes'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to open decision', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open decision: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCloseDecision(String decisionId) async {
    try {
      await ref
          .read(sessionDecisionsProvider(widget.sessionId).notifier)
          .closeDecision(decisionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Decision closed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to close decision', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close decision: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showViewResultsDialog(DecisionModel decision, AppLocalizations l10n) {
    final tally = decision.tally;
    if (tally == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No voting results available'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => _ViewResultsDialog(
            decision: decision,
            sessionId: widget.sessionId,
            l10n: l10n,
          ),
    );
  }
}

// View Results Dialog - Shows detailed voting results
class _ViewResultsDialog extends ConsumerStatefulWidget {
  final DecisionModel decision;
  final String sessionId;
  final AppLocalizations l10n;

  const _ViewResultsDialog({
    required this.decision,
    required this.sessionId,
    required this.l10n,
  });

  @override
  ConsumerState<_ViewResultsDialog> createState() => _ViewResultsDialogState();
}

class _ViewResultsDialogState extends ConsumerState<_ViewResultsDialog> {
  List<VoteModel>? _votes;
  bool _isLoadingVotes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVotes();
    });
  }

  Future<void> _loadVotes() async {
    setState(() => _isLoadingVotes = true);

    try {
      final votes = await ref
          .read(decisionServiceProvider)
          .getDecisionVotes(widget.decision.id);

      if (mounted) {
        setState(() {
          _votes = votes;
          _isLoadingVotes = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load votes', e);
      if (mounted) {
        setState(() => _isLoadingVotes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tally = widget.decision.tally!;
    final total = tally.accepted + tally.denied + tally.abstained;
    final passed = tally.passed;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      passed
                          ? [AppColors.success, const Color(0xFF2E7D32)]
                          : [AppColors.error, const Color(0xFFC62828)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.l10n.votingResults,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.decision.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          passed ? Icons.check_circle : Icons.cancel,
                          color: passed ? AppColors.success : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          passed ? 'PASSED' : 'FAILED',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: passed ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vote Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildVoteStat(
                          widget.l10n.accepted,
                          tally.accepted,
                          tally.acceptPercentage,
                          AppColors.voteYes,
                        ),
                        _buildVoteStat(
                          widget.l10n.denied,
                          tally.denied,
                          tally.denyPercentage,
                          AppColors.voteNo,
                        ),
                        _buildVoteStat(
                          widget.l10n.abstain,
                          tally.abstained,
                          tally.abstainPercentage,
                          AppColors.voteAbstain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Summary Stats
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.info.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat('Total Votes', total.toString()),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          _buildSummaryStat(
                            'Active Members',
                            tally.activeBase.toString(),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          _buildSummaryStat(
                            'Turnout',
                            '${tally.turnoutPercentage.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Individual Votes
                    if (_isLoadingVotes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_votes != null && _votes!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.how_to_vote,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Individual Votes (${_votes!.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._votes!.map((vote) => _buildVoteCard(vote)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteStat(
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildVoteCard(VoteModel vote) {
    Color choiceColor;
    IconData choiceIcon;
    String choiceLabel;

    switch (vote.choice) {
      case VoteChoice.accept:
        choiceColor = AppColors.voteYes;
        choiceIcon = Icons.thumb_up;
        choiceLabel = widget.l10n.accepted;
        break;
      case VoteChoice.deny:
        choiceColor = AppColors.voteNo;
        choiceIcon = Icons.thumb_down;
        choiceLabel = widget.l10n.denied;
        break;
      case VoteChoice.abstain:
        choiceColor = AppColors.voteAbstain;
        choiceIcon = Icons.remove_circle_outline;
        choiceLabel = widget.l10n.abstain;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [choiceColor.withOpacity(0.1), choiceColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: choiceColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: choiceColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Choice Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: choiceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: choiceColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(choiceIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),

            // Vote Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    choiceLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: choiceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User ${vote.userId.substring(0, vote.userId.length > 8 ? 8 : vote.userId.length)}...',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Timestamp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(vote.castAt.toLocal()),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
}

// Create Decision Dialog
class _CreateDecisionDialog extends StatefulWidget {
  final String sessionId;
  final AppLocalizations l10n;

  const _CreateDecisionDialog({required this.sessionId, required this.l10n});

  @override
  State<_CreateDecisionDialog> createState() => _CreateDecisionDialogState();
}

class _CreateDecisionDialogState extends State<_CreateDecisionDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _allowRecast = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.ballot, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                widget.l10n.createDecision,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: widget.l10n.decisionTitle,
                  hint: 'e.g., Approve Budget 2025',
                  controller: _titleController,
                  prefixIcon: const Icon(Icons.title),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: widget.l10n.description,
                  hint: 'Describe what members are voting on',
                  controller: _descriptionController,
                  prefixIcon: const Icon(Icons.description),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(widget.l10n.allowRecast),
                  subtitle: const Text(
                    'Allow members to change their vote',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _allowRecast,
                  onChanged:
                      (value) => setState(() => _allowRecast = value ?? false),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
              child: Text(widget.l10n.cancel),
            ),
            CustomButton(
              text: widget.l10n.create,
              icon: Icons.add,
              onPressed: _isCreating ? null : () => _handleCreate(ref),
              isLoading: _isCreating,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCreate(WidgetRef ref) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Decision title is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isCreating = true);

    try {
      await ref
          .read(sessionDecisionsProvider(widget.sessionId).notifier)
          .createDecision(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            allowRecast: _allowRecast,
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Decision created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to create decision', e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create decision: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
