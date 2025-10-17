import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/voting_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';

class MemberHomeScreen extends ConsumerStatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  ConsumerState<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends ConsumerState<MemberHomeScreen> {
  final Set<String> _joinedSessions = {};
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    // Load sessions and voting data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.info('MemberHomeScreen: Loading sessions on screen init');
      ref.read(sessionProvider.notifier).loadSessions();
      ref.read(currentVotingProvider.notifier).loadCurrentVoting();
    });
  }

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Future<void> _handleJoinSession(String sessionId) async {
    if (_isJoining) return;

    setState(() => _isJoining = true);

    try {
      await ref.read(sessionProvider.notifier).joinSession(sessionId);
      if (mounted) {
        setState(() => _joinedSessions.add(sessionId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined session'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('MemberHomeScreen: Failed to join session', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join session: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _handleLeaveSession(String sessionId) async {
    if (_isJoining) return;

    setState(() => _isJoining = true);

    try {
      await ref.read(sessionProvider.notifier).leaveSession(sessionId);
      if (mounted) {
        setState(() => _joinedSessions.remove(sessionId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left session'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('MemberHomeScreen: Failed to leave session', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave session: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final sessionState = ref.watch(sessionProvider);
    final votingState = ref.watch(currentVotingProvider);
    final l10n = AppLocalizations.of(context);

    final userName = authState.maybeWhen(
      data: (user) => user?.name.split(' ').first ?? l10n.member,
      orElse: () => l10n.member,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait<void>([
              ref.read(sessionProvider.notifier).refresh(),
              ref.read(currentVotingProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: Text(
                          '${_getGreeting(context)},',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Active Sessions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.activeSessions,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Check if there's an active session
                      sessionState.when(
                        data: (sessions) {
                          // Filter and sort active sessions (newest first)
                          final activeSessions =
                              sessions.where((s) => s.isActive).toList()..sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt),
                              );

                          if (activeSessions.isEmpty) {
                            // No active sessions
                            return FadeInUp(
                              child: Container(
                                padding: const EdgeInsets.all(40),
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
                                  border: Border.all(
                                    color: AppColors.divider,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 80,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      l10n.noActiveSession,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.noSessionsCurrently,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Display active sessions
                          return Column(
                            children:
                                activeSessions.map((session) {
                                  return FadeInUp(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: _buildActiveSessionCard(
                                        session: session,
                                        votingState: votingState,
                                        l10n: l10n,
                                        context: context,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (error, stack) => CustomCard(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppColors.error.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.error,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActiveSessionCard({
    required session,
    required AsyncValue votingState,
    required AppLocalizations l10n,
    required BuildContext context,
  }) {
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
            blurRadius: 25,
            offset: const Offset(0, 12),
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
              top: -30,
              child: Icon(
                Icons.event,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    session.speaker,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

                  const SizedBox(height: 20),

                  // Join/Leave Session Button
                  _buildJoinLeaveButton(session, l10n),

                  const SizedBox(height: 20),

                  // Voting Decision Section
                  votingState.when(
                    data: (voting) {
                      if (voting == null || !voting.isOpen) {
                        // No active voting
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.noActiveDecision,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Active voting decision
                      final isExpired =
                          voting.closeAt != null &&
                          DateTime.now().isAfter(voting.closeAt!);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.poll,
                                color: Colors.white.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.activeDecision,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voting.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (voting.description != null &&
                                    voting.description!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    voting.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),

                                // Timer or Status
                                if (isExpired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.timer_off,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.votingEnded,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (voting.closeAt != null)
                                  _VotingTimerWhite(
                                    endTime: voting.closeAt!,
                                    l10n: l10n,
                                  ),

                                const SizedBox(height: 20),

                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          isExpired
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow:
                                          !isExpired
                                              ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap:
                                            isExpired
                                                ? null
                                                : () => context.go(
                                                  '/member/voting',
                                                ),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isExpired
                                                    ? Icons.block
                                                    : Icons.how_to_vote,
                                                color:
                                                    isExpired
                                                        ? Colors.white
                                                            .withOpacity(0.6)
                                                        : AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isExpired
                                                    ? l10n.votingEnded
                                                    : l10n.voteNow,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isExpired
                                                          ? Colors.white
                                                              .withOpacity(0.6)
                                                          : AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading:
                        () => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                    error:
                        (_, __) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.error,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
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
    );
  }

  Widget _buildJoinLeaveButton(dynamic session, AppLocalizations l10n) {
    final isJoined = _joinedSessions.contains(session.id);

    return GestureDetector(
      onTap:
          _isJoining
              ? null
              : () {
                if (isJoined) {
                  _handleLeaveSession(session.id);
                } else {
                  _handleJoinSession(session.id);
                }
              },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              isJoined
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isJoining)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                isJoined ? Icons.exit_to_app : Icons.login,
                color: isJoined ? Colors.white : AppColors.primary,
                size: 20,
              ),
            const SizedBox(width: 12),
            Text(
              isJoined ? l10n.leaveSession : l10n.joinSession,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isJoined ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Countdown Timer Widget (White version for gradient backgrounds)
class _VotingTimerWhite extends StatefulWidget {
  final DateTime endTime;
  final AppLocalizations l10n;

  const _VotingTimerWhite({required this.endTime, required this.l10n});

  @override
  State<_VotingTimerWhite> createState() => _VotingTimerWhiteState();
}

class _VotingTimerWhiteState extends State<_VotingTimerWhite> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);

    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining.inSeconds <= 0;
    final isUrgent = _remaining.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            isExpired || isUrgent
                ? Colors.white
                : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 18,
            color:
                isExpired
                    ? AppColors.error
                    : isUrgent
                    ? AppColors.warning
                    : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            isExpired
                ? widget.l10n.votingEnded
                : '${widget.l10n.timeRemaining}: ${_formatDuration(_remaining)}',
            style: TextStyle(
              color:
                  isExpired
                      ? AppColors.error
                      : isUrgent
                      ? AppColors.warning
                      : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Countdown Timer Widget
class _VotingTimer extends StatefulWidget {
  final DateTime endTime;
  final AppLocalizations l10n;

  const _VotingTimer({required this.endTime, required this.l10n});

  @override
  State<_VotingTimer> createState() => _VotingTimerState();
}

class _VotingTimerState extends State<_VotingTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);

    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining.inSeconds <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isExpired
                ? AppColors.error.withOpacity(0.2)
                : _remaining.inMinutes < 5
                ? AppColors.warning.withOpacity(0.2)
                : AppColors.info.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 18,
            color:
                isExpired
                    ? AppColors.error
                    : _remaining.inMinutes < 5
                    ? AppColors.warning
                    : AppColors.info,
          ),
          const SizedBox(width: 8),
          Text(
            isExpired
                ? widget.l10n.votingEnded
                : '${widget.l10n.timeRemaining}: ${_formatDuration(_remaining)}',
            style: TextStyle(
              color:
                  isExpired
                      ? AppColors.error
                      : _remaining.inMinutes < 5
                      ? AppColors.warning
                      : AppColors.info,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
