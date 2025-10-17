import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/member/home/screens/member_home_screen.dart';
import '../../features/member/agenda/screens/agenda_screen.dart';
import '../../features/member/voting/screens/voting_screen.dart';
import '../../features/member/documents/screens/documents_screen.dart';
import '../../features/member/chat/screens/chat_screen.dart';
import '../../features/member/speaker/screens/speaker_screen.dart';
import '../../features/member/profile/screens/profile_screen.dart';
import '../../features/admin/dashboard/screens/admin_dashboard_screen.dart';
import '../../features/admin/sessions/screens/sessions_screen.dart';
import '../../features/admin/members/screens/members_management_screen.dart';
import '../../features/admin/voting_control/screens/voting_control_screen.dart';
import '../../features/admin/documents/screens/admin_documents_screen.dart';
import '../../features/admin/attendance/screens/attendance_screen.dart';
import '../../features/admin/reports/screens/reports_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      final userRole = authState.maybeWhen(
        data: (user) => user?.role,
        orElse: () => null,
      );

      final isLoggingIn = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login page, redirect based on role
      if (isAuthenticated && isLoggingIn) {
        if (userRole?.toUpperCase() == 'ADMIN') {
          return '/admin/dashboard';
        } else {
          return '/member/home';
        }
      }

      // Check role-based access
      if (isAuthenticated) {
        final isMemberRoute = state.matchedLocation.startsWith('/member');
        final isAdminRoute = state.matchedLocation.startsWith('/admin');
        final isAdmin = userRole?.toUpperCase() == 'ADMIN';

        if (isMemberRoute && isAdmin) {
          return '/admin/dashboard';
        }

        if (isAdminRoute && !isAdmin) {
          return '/member/home';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Member Routes
      GoRoute(
        path: '/member/home',
        builder: (context, state) => const MemberHomeScreen(),
      ),
      GoRoute(
        path: '/member/agenda',
        builder: (context, state) => const AgendaScreen(),
      ),
      GoRoute(
        path: '/member/voting',
        builder: (context, state) => const VotingScreen(),
      ),
      GoRoute(
        path: '/member/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/member/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/member/speaker',
        builder: (context, state) => const SpeakerScreen(),
      ),
      GoRoute(
        path: '/member/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/sessions',
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/admin/members',
        builder: (context, state) => const MembersManagementScreen(),
      ),
      GoRoute(
        path: '/admin/voting-control',
        builder: (context, state) => const VotingControlScreen(),
      ),
      GoRoute(
        path: '/admin/documents',
        builder: (context, state) => const AdminDocumentsScreen(),
      ),
      GoRoute(
        path: '/admin/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
    ],
  );
});
