import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:intl/intl.dart';

class FeeDashboardScreen extends StatefulWidget {
  const FeeDashboardScreen({super.key});

  @override
  State<FeeDashboardScreen> createState() => _FeeDashboardScreenState();
}

class _FeeDashboardScreenState extends State<FeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feeProv = context.read<FeeProvider>();
      feeProv.fetchAllPayments();
      feeProv.fetchFeeSummary();
      feeProv.fetchOverdueMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => context.push('/fees/reminders'),
          ),
        ],
      ),
      body: Consumer<FeeProvider>(
        builder: (context, fees, _) {
          if (fees.isLoading && fees.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await fees.fetchAllPayments();
              await fees.fetchFeeSummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(fees, currency),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // Payment Method Breakdown
                  _buildPaymentMethodBreakdown(fees, currency),
                  const SizedBox(height: 20),

                  // Due Date Alerts
                  _buildDueDateAlerts(fees),
                  const SizedBox(height: 20),

                  // Recent Payments
                  _buildRecentPayments(fees),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fees/record'),
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildSummaryCards(FeeProvider fees, NumberFormat currency) {
    return Column(
      children: [
        // Main Stats Row
        Row(
          children: [
            Expanded(child: _summaryCard(
              'Total Collected',
              currency.format(fees.totalCollected),
              Icons.account_balance_wallet,
              AppColors.success,
            )),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard(
              'Total Due',
              currency.format(fees.totalDue),
              Icons.money_off,
              AppColors.danger,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _summaryCard(
              'Monthly Collection',
              currency.format(fees.monthlyCollection),
              Icons.calendar_month,
              AppColors.info,
            )),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard(
              'Today\'s Collection',
              currency.format(fees.todayCollection),
              Icons.today,
              AppColors.primary,
            )),
          ],
        ),
        const SizedBox(height: 12),
        // Count Stats
        Row(
          children: [
            Expanded(child: _countCard('Paid', fees.paidCount, AppColors.success)),
            const SizedBox(width: 8),
            Expanded(child: _countCard('Unpaid', fees.unpaidCount, AppColors.danger)),
            const SizedBox(width: 8),
            Expanded(child: _countCard('Overdue', fees.overdueCount, AppColors.warning)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _countCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionTile(Icons.add_circle, 'Record\nPayment', AppColors.primary, () => context.push('/fees/record')),
            const SizedBox(width: 10),
            _actionTile(Icons.warning_amber, 'Overdue\nMembers', AppColors.danger, () => context.push('/fees/overdue')),
            const SizedBox(width: 10),
            _actionTile(Icons.notifications, 'Send\nReminders', AppColors.warning, () => context.push('/fees/reminders')),
            const SizedBox(width: 10),
            _actionTile(Icons.receipt_long, 'All\nPayments', AppColors.info, () {
              // Show all payments in a bottom sheet or new screen
            }),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
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
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBreakdown(FeeProvider fees, NumberFormat currency) {
    final breakdown = fees.paymentMethodBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final methodIcons = {
      'cash': Icons.money,
      'upi': Icons.qr_code,
      'card': Icons.credit_card,
      'bank_transfer': Icons.account_balance,
    };

    final methodColors = {
      'cash': AppColors.success,
      'upi': AppColors.info,
      'card': AppColors.warning,
      'bank_transfer': AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Collection by Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...breakdown.entries.map((entry) {
            final total = fees.totalCollected;
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            final color = methodColors[entry.key] ?? AppColors.primary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(methodIcons[entry.key] ?? Icons.payment, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(currency.format(entry.value), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDueDateAlerts(FeeProvider fees) {
    final overduePayments = fees.payments.where((p) => p.isOverdue).toList();
    if (overduePayments.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.danger),
              const SizedBox(width: 8),
              const Text('Overdue Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.danger)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/fees/overdue'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${overduePayments.length} members have overdue payments',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPayments(FeeProvider fees) {
    final recent = fees.payments.where((p) => p.isPaid).toList()
      ..sort((a, b) => (b.paymentDate ?? DateTime(2000)).compareTo(a.paymentDate ?? DateTime(2000)));

    if (recent.isEmpty) {
      return const Center(child: Text('No recent payments', style: TextStyle(color: AppColors.textSecondary)));
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recent.take(10).map((payment) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.userName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${payment.paymentMethod.toUpperCase()} • ${payment.paymentDate != null ? dateFormat.format(payment.paymentDate!) : '-'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${payment.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
