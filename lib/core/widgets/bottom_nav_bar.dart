import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_outlined),
            activeIcon: const Icon(Icons.folder),
            label: l10n.documents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.how_to_vote_outlined),
            activeIcon: const Icon(Icons.how_to_vote),
            label: l10n.voting,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat),
            label: l10n.chat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/member/home');
        break;
      case 1:
        context.go('/member/documents');
        break;
      case 2:
        context.go('/member/voting');
        break;
      case 3:
        context.go('/member/chat');
        break;
      case 4:
        context.go('/member/profile');
        break;
    }
  }
}
