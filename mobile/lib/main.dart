import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/config/router.dart';
import 'package:gym_master/providers/auth_provider.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:gym_master/providers/plan_provider.dart';
import 'package:gym_master/providers/dashboard_provider.dart';
import 'package:gym_master/providers/attendance_provider.dart';
import 'package:gym_master/providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const GymMasterApp());
}

class GymMasterApp extends StatelessWidget {
  const GymMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'GymMaster',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router(auth),
          );
        },
      ),
    );
  }
}
