import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../localization/app_localizations.dart';

class AdminSidebar extends ConsumerWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(languageProvider);

    final userName = authState.maybeWhen(
      data: (user) => user?.name ?? l10n.admin,
      orElse: () => l10n.admin,
    );

    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/logo.svg.png',
                    height: 50,
                    width: 50,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Administrator', // Can be localized if needed
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard,
                    label: l10n.dashboard,
                    route: '/admin/dashboard',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.event,
                    label: l10n.sessions,
                    route: '/admin/sessions',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.people,
                    label: l10n.members,
                    route: '/admin/members',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.how_to_vote,
                    label: l10n.votingControl,
                    route: '/admin/voting-control',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.folder,
                    label: l10n.documents,
                    route: '/admin/documents',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.check_circle,
                    label: l10n.attendance,
                    route: '/admin/attendance',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    label: l10n.reports,
                    route: '/admin/reports',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text(l10n.language),
              trailing: Text(
                locale.languageCode == 'ar' ? 'العربية' : 'English',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                _showLanguageDialog(context, ref, l10n);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                l10n.logout,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.selectLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.english),
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage('en');
                    Navigator.pop(dialogContext);
                  },
                  trailing:
                      ref.watch(languageProvider).languageCode == 'en'
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                ),
                ListTile(
                  leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.arabic),
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage('ar');
                    Navigator.pop(dialogContext);
                  },
                  trailing:
                      ref.watch(languageProvider).languageCode == 'ar'
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          context.go(route);
          Navigator.of(context).pop(); // Close drawer
        },
      ),
    );
  }
}
