import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:gym_master/providers/plan_provider.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchAllMembers();
      context.read<FeeProvider>().fetchAllPayments();
      context.read<PlanProvider>().fetchAllPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Consumer3<MemberProvider, FeeProvider, PlanProvider>(
        builder: (context, members, fees, plans, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Summary
                _sectionTitle('Revenue Summary'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _revenueItem('Total Revenue', currency.format(fees.totalCollected)),
                          _revenueItem('Pending Due', currency.format(fees.totalDue)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _revenueItem('Monthly', currency.format(fees.monthlyCollection)),
                          _revenueItem('Today', currency.format(fees.todayCollection)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Member Statistics
                _sectionTitle('Member Statistics'),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                  children: [
                    _statBox('Total', '${members.totalMembers}', Icons.people, AppColors.primary),
                    _statBox('Active', '${members.activeMembers}', Icons.person_pin, AppColors.success),
                    _statBox('Expired', '${members.expiredMembers}', Icons.warning, AppColors.danger),
                    _statBox('Blocked', '${members.blockedMembers}', Icons.block, AppColors.blocked),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment Method Distribution
                _sectionTitle('Payment Methods'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                  ),
                  child: Column(
                    children: fees.paymentMethodBreakdown.entries.map((entry) {
                      final percentage = fees.totalCollected > 0
                          ? (entry.value / fees.totalCollected * 100).toStringAsFixed(1)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(entry.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500))),
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: fees.totalCollected > 0 ? entry.value / fees.totalCollected : 0,
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 50,
                              child: Text('$percentage%', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Fee Overview
                _sectionTitle('Fee Overview'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _feeBox('Paid', fees.paidCount, AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _feeBox('Unpaid', fees.unpaidCount, AppColors.danger)),
                    const SizedBox(width: 12),
                    Expanded(child: _feeBox('Overdue', fees.overdueCount, AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 24),

                // Plan Stats
                _sectionTitle('Plans'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Plans', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('${plans.totalPlans}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const Divider(),
                      ...plans.plans.map((plan) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.card_membership, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(plan.planName)),
                            Text('₹${plan.monthlyPlanAmount ?? '-'}/mo', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _revenueItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
