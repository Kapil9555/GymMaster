import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:gym_master/providers/plan_provider.dart';
import 'package:gym_master/providers/dashboard_provider.dart';
import 'package:gym_master/providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final dashboard = context.read<DashboardProvider>();
    final members = context.read<MemberProvider>();
    final fees = context.read<FeeProvider>();
    final plans = context.read<PlanProvider>();
    await dashboard.loadDashboard(members, fees, plans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Consumer3<MemberProvider, FeeProvider, DashboardProvider>(
        builder: (context, members, fees, dashboard, _) {
          if (dashboard.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Row
                  _buildQuickStats(members, fees),
                  const SizedBox(height: 20),

                  // Today's Overview
                  _buildSectionTitle('Today\'s Overview'),
                  const SizedBox(height: 12),
                  _buildTodayOverview(fees),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // Membership Expiry Alerts
                  _buildSectionTitle('Expiry Alerts'),
                  const SizedBox(height: 12),
                  _buildExpiryAlerts(members),
                  const SizedBox(height: 20),

                  // Collection Overview
                  _buildSectionTitle('Collection Overview'),
                  const SizedBox(height: 12),
                  _buildCollectionOverview(fees),
                  const SizedBox(height: 20),

                  // Member Status Distribution
                  _buildSectionTitle('Member Status'),
                  const SizedBox(height: 12),
                  _buildMemberStatus(members),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickStats(MemberProvider members, FeeProvider fees) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statCard('Total Members', '${members.totalMembers}', Icons.people, AppColors.primary),
        _statCard('Active', '${members.activeMembers}', Icons.person_pin, AppColors.success),
        _statCard('Today\'s Collection', '₹${fees.todayCollection.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.info),
        _statCard('Overdue', '${fees.overdueCount}', Icons.warning_amber, AppColors.danger),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOverview(FeeProvider fees) {
    final attendance = context.read<AttendanceProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _todayItem(Icons.attach_money, '₹${fees.todayCollection.toStringAsFixed(0)}', 'Collection'),
          Container(width: 1, height: 50, color: Colors.white30),
          _todayItem(Icons.people, '${attendance.todayCount}', 'Attendance'),
          Container(width: 1, height: 50, color: Colors.white30),
          _todayItem(Icons.warning, '${fees.overdueCount}', 'Overdue'),
        ],
      ),
    );
  }

  Widget _todayItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _actionButton(Icons.person_add, 'Add\nMember', () => context.push('/members/add')),
        const SizedBox(width: 12),
        _actionButton(Icons.payment, 'Record\nPayment', () => context.push('/fees/record')),
        const SizedBox(width: 12),
        _actionButton(Icons.fingerprint, 'Mark\nAttendance', () => context.go('/attendance')),
        const SizedBox(width: 12),
        _actionButton(Icons.money_off, 'Overdue\nFees', () => context.push('/fees/overdue')),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryAlerts(MemberProvider members) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _expiryRow('Expiring in 1-3 days', members.expiringIn3Days.length, AppColors.danger),
          const Divider(),
          _expiryRow('Expiring in 4-7 days', members.expiringIn7Days.length, AppColors.warning),
          const Divider(),
          _expiryRow('Expiring in 8-15 days', members.expiringIn15Days.length, AppColors.info),
        ],
      ),
    );
  }

  Widget _expiryRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionOverview(FeeProvider fees) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _collectionItem('Monthly', formatter.format(fees.monthlyCollection), AppColors.success),
              _collectionItem('Total Collected', formatter.format(fees.totalCollected), AppColors.primary),
              _collectionItem('Total Due', formatter.format(fees.totalDue), AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _collectionItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMemberStatus(MemberProvider members) {
    return Row(
      children: [
        _statusChip('Active', members.activeMembers, AppColors.success),
        const SizedBox(width: 8),
        _statusChip('Inactive', members.inactiveMembers, AppColors.inactive),
        const SizedBox(width: 8),
        _statusChip('Expired', members.expiredMembers, AppColors.expired),
        const SizedBox(width: 8),
        _statusChip('Blocked', members.blockedMembers, AppColors.blocked),
      ],
    );
  }

  Widget _statusChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
