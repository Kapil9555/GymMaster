import 'package:go_router/go_router.dart';
import 'package:gym_master/providers/auth_provider.dart';
import 'package:gym_master/screens/splash_screen.dart';
import 'package:gym_master/screens/auth/login_screen.dart';
import 'package:gym_master/screens/auth/register_screen.dart';
import 'package:gym_master/screens/auth/forgot_password_screen.dart';
import 'package:gym_master/screens/home/home_shell.dart';
import 'package:gym_master/screens/dashboard/dashboard_screen.dart';
import 'package:gym_master/screens/members/member_list_screen.dart';
import 'package:gym_master/screens/members/add_member_screen.dart';
import 'package:gym_master/screens/members/edit_member_screen.dart';
import 'package:gym_master/screens/members/member_detail_screen.dart';
import 'package:gym_master/screens/fees/fee_dashboard_screen.dart';
import 'package:gym_master/screens/fees/record_payment_screen.dart';
import 'package:gym_master/screens/fees/payment_history_screen.dart';
import 'package:gym_master/screens/fees/overdue_members_screen.dart';
import 'package:gym_master/screens/fees/fee_reminders_screen.dart';
import 'package:gym_master/screens/plans/plan_list_screen.dart';
import 'package:gym_master/screens/plans/create_plan_screen.dart';
import 'package:gym_master/screens/plans/plan_detail_screen.dart';
import 'package:gym_master/screens/attendance/attendance_screen.dart';
import 'package:gym_master/screens/reports/reports_screen.dart';
import 'package:gym_master/screens/settings/settings_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';
        final isSplash = state.matchedLocation == '/';

        if (isSplash) return null;
        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/members',
              builder: (context, state) => const MemberListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddMemberScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => MemberDetailScreen(
                    memberId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) => EditMemberScreen(
                    memberId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/fees',
              builder: (context, state) => const FeeDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'record',
                  builder: (context, state) => const RecordPaymentScreen(),
                ),
                GoRoute(
                  path: 'record/:memberId',
                  builder: (context, state) => RecordPaymentScreen(
                    memberId: state.pathParameters['memberId'],
                  ),
                ),
                GoRoute(
                  path: 'history/:memberId',
                  builder: (context, state) => PaymentHistoryScreen(
                    memberId: state.pathParameters['memberId']!,
                  ),
                ),
                GoRoute(
                  path: 'overdue',
                  builder: (context, state) => const OverdueMembersScreen(),
                ),
                GoRoute(
                  path: 'reminders',
                  builder: (context, state) => const FeeRemindersScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/plans',
              builder: (context, state) => const PlanListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreatePlanScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => PlanDetailScreen(
                    planId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/attendance',
              builder: (context, state) => const AttendanceScreen(),
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
