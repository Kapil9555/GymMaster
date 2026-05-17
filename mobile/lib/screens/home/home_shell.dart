import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/auth_provider.dart';

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {

  static const _navItems = [
    ('/members', Icons.people, 'Members'),
    ('/attendance', Icons.fingerprint, 'Attendance'),
    ('/reports', Icons.bar_chart, 'Reports'),
    ('/settings', Icons.grid_view, 'More'),
  ];

  void _onItemTapped(int index) {
    context.go(_navItems[index].$1);
  }

  int _getSelectedIndex(String location) {
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(location);
    final showBottomNav = !location.contains('/add') && 
                          !location.contains('/edit') && 
                          !location.contains('/record');

    return Scaffold(
      drawer: _buildDrawer(context),
      body: widget.child,
      bottomNavigationBar: showBottomNav ? BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        items: _navItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.$2),
          label: item.$3,
        )).toList(),
      ) : null,
      floatingActionButton: showBottomNav ? FloatingActionButton.extended(
        onPressed: () => context.push('/members/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.fitness_center, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.user?.name ?? 'GymMaster',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  auth.user?.email ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard', () => context.go('/dashboard')),
          _drawerItem(Icons.people, 'Members', () => context.go('/members')),
          _drawerItem(Icons.payment, 'Fee Management', () => context.go('/fees')),
          _drawerItem(Icons.card_membership, 'Plans', () => context.go('/plans')),
          _drawerItem(Icons.fingerprint, 'Attendance', () => context.go('/attendance')),
          _drawerItem(Icons.bar_chart, 'Reports', () => context.go('/reports')),
          _drawerItem(Icons.money_off, 'Overdue Fees', () => context.go('/fees/overdue')),
          _drawerItem(Icons.notifications, 'Fee Reminders', () => context.go('/fees/reminders')),
          const Divider(),
          _drawerItem(Icons.settings, 'Settings', () => context.go('/settings')),
          _drawerItem(Icons.logout, 'Logout', () async {
            await auth.logout();
            if (context.mounted) context.go('/login');
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
