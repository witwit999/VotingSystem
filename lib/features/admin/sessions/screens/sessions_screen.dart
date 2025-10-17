import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../providers/session_provider.dart';
import '../../../../models/session_model.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load ALL sessions when screen opens (DRAFT, LIVE, PAUSED, CLOSED, ARCHIVED)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.sessionsManagement),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/sessions'),
      body: sessionState.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return FadeInUp(child: _buildEmptyState(context, l10n));
          }

          // Sort sessions: LIVE first, then DRAFT, PAUSED, CLOSED, ARCHIVED
          final sortedSessions = _sortSessions(sessions);

          return RefreshIndicator(
            onRefresh: () => ref.read(sessionProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: sortedSessions.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildSessionCard(
                    context,
                    ref,
                    sortedSessions[index],
                    index,
                    l10n,
                  ),
                );
              },
            ),
          );
        },
        loading: () => LoadingIndicator(message: l10n.loadingSessions),
        error:
            (error, _) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(sessionProvider.notifier).refresh(),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context, ref, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSession),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _handleSessionAction(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    String action,
    AppLocalizations l10n,
  ) async {
    try {
      AppLogger.info(
        'Admin: Performing action "$action" on session: ${session.id}',
      );

      switch (action) {
        case 'open':
          await ref.read(sessionProvider.notifier).openSession(session.id);
          break;
        case 'pause':
          await ref.read(sessionProvider.notifier).pauseSession(session.id);
          break;
        case 'close':
          await ref.read(sessionProvider.notifier).closeSession(session.id);
          break;
        case 'archive':
          await ref.read(sessionProvider.notifier).archiveSession(session.id);
          break;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session ${action}ed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Admin: Failed to $action session', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action session: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    int index,
    AppLocalizations l10n,
  ) {
    // Alternating gradient colors
    final gradients = [
      [AppColors.primary, const Color(0xFF1565C0)],
      [AppColors.info, const Color(0xFF1976D2)],
      [const Color(0xFF7E57C2), const Color(0xFF5E35B1)],
      [const Color(0xFF26A69A), const Color(0xFF00897B)],
    ];

    final activeGradient = [AppColors.success, const Color(0xFF2E7D32)];
    final inactiveGradients = gradients;

    final gradientIndex = index % inactiveGradients.length;
    final colors =
        session.isActive ? activeGradient : inactiveGradients[gradientIndex];

    return GestureDetector(
      onTap: () {
        AppLogger.info('Admin: Navigating to session details: ${session.id}');
        context.push('/admin/sessions/${session.id}');
      },
      child: Container(
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
                  Icons.event_note,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and active badge
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildStatusBadge(session.status, colors),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Session details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.speaker,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      session.speaker,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (session.description != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        session.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action buttons based on session status
                    _buildSessionActions(context, ref, session, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ); // GestureDetector
  }

  Widget _buildSessionActions(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    AppLocalizations l10n,
  ) {
    // Determine which actions to show based on session status
    List<Widget> actionButtons = [];

    switch (session.status) {
      case SessionStatus.draft:
        actionButtons = [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.play_arrow,
              label: l10n.openSession,
              onPressed:
                  () =>
                      _handleSessionAction(context, ref, session, 'open', l10n),
            ),
          ),
        ];
        break;

      case SessionStatus.live:
        actionButtons = [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.pause,
              label: l10n.pauseSession,
              onPressed:
                  () => _handleSessionAction(
                    context,
                    ref,
                    session,
                    'pause',
                    l10n,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.stop,
              label: l10n.closeSession,
              isDestructive: true,
              onPressed:
                  () => _handleSessionAction(
                    context,
                    ref,
                    session,
                    'close',
                    l10n,
                  ),
            ),
          ),
        ];
        break;

      case SessionStatus.paused:
        actionButtons = [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.play_arrow,
              label: l10n.openSession,
              onPressed:
                  () =>
                      _handleSessionAction(context, ref, session, 'open', l10n),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.stop,
              label: l10n.closeSession,
              isDestructive: true,
              onPressed:
                  () => _handleSessionAction(
                    context,
                    ref,
                    session,
                    'close',
                    l10n,
                  ),
            ),
          ),
        ];
        break;

      case SessionStatus.closed:
        actionButtons = [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.archive,
              label: l10n.archiveSession,
              onPressed:
                  () => _handleSessionAction(
                    context,
                    ref,
                    session,
                    'archive',
                    l10n,
                  ),
            ),
          ),
        ];
        break;

      case SessionStatus.archived:
        actionButtons = [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                'Archived',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ];
        break;
    }

    return Row(children: actionButtons);
  }

  Widget _buildStatusBadge(SessionStatus status, List<Color> colors) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case SessionStatus.live:
        badgeColor = AppColors.success;
        statusText = 'LIVE';
        break;
      case SessionStatus.draft:
        badgeColor = AppColors.warning;
        statusText = 'DRAFT';
        break;
      case SessionStatus.paused:
        badgeColor = AppColors.info;
        statusText = 'PAUSED';
        break;
      case SessionStatus.closed:
        badgeColor = AppColors.textSecondary;
        statusText = 'CLOSED';
        break;
      case SessionStatus.archived:
        badgeColor = AppColors.textHint;
        statusText = 'ARCHIVED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isDestructive
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDestructive
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
            Icons.event_busy,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noSessionsAvailable,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.createNewSession,
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

  List<SessionModel> _sortSessions(List<SessionModel> sessions) {
    final sortedSessions = List<SessionModel>.from(sessions);

    // Define priority order: LIVE > DRAFT > PAUSED > CLOSED > ARCHIVED
    final statusPriority = {
      SessionStatus.live: 1,
      SessionStatus.draft: 2,
      SessionStatus.paused: 3,
      SessionStatus.closed: 4,
      SessionStatus.archived: 5,
    };

    sortedSessions.sort((a, b) {
      final aPriority = statusPriority[a.status] ?? 99;
      final bPriority = statusPriority[b.status] ?? 99;

      // Primary sort by status priority
      final priorityComparison = aPriority.compareTo(bPriority);
      if (priorityComparison != 0) return priorityComparison;

      // Secondary sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    AppLogger.debug(
      'SessionsScreen: Sorted ${sortedSessions.length} sessions (LIVE first)',
    );
    return sortedSessions;
  }

  void _showCreateSessionDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CreateSessionDialog(ref: ref, l10n: l10n),
    );
  }
}

// Create Session Dialog
class _CreateSessionDialog extends StatefulWidget {
  final WidgetRef ref;
  final AppLocalizations l10n;

  const _CreateSessionDialog({required this.ref, required this.l10n});

  @override
  State<_CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<_CreateSessionDialog> {
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.sessionTitle + ' is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isCreating = true);

    try {
      AppLogger.info('Admin: Creating session: ${_nameController.text}');

      await widget.ref
          .read(sessionProvider.notifier)
          .createSession(_nameController.text.trim());

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.sessionCreated),
          backgroundColor: AppColors.success,
        ),
      );

      AppLogger.info('Admin: Session created successfully');
    } catch (e) {
      AppLogger.error('Admin: Failed to create session', e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create session: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.l10n.createSession,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter session name to create a new draft session',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: widget.l10n.sessionTitle,
              hint: 'e.g., Morning Session, Budget Discussion',
              controller: _nameController,
              prefixIcon: const Icon(Icons.event),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Session will be created as DRAFT. Open it to make it available to members.',
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
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(widget.l10n.cancel),
        ),
        CustomButton(
          text: widget.l10n.createSession,
          icon: Icons.add,
          onPressed: _isCreating ? null : _handleCreate,
          isLoading: _isCreating,
        ),
      ],
    );
  }
}
