import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:intl/intl.dart';

class FeeRemindersScreen extends StatefulWidget {
  const FeeRemindersScreen({super.key});

  @override
  State<FeeRemindersScreen> createState() => _FeeRemindersScreenState();
}

class _FeeRemindersScreenState extends State<FeeRemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().fetchAllPayments();
      context.read<FeeProvider>().fetchReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Due Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: Consumer<FeeProvider>(
        builder: (context, fees, _) {
          if (fees.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final weekEnd = today.add(const Duration(days: 7));
          final monthEnd = DateTime(now.year, now.month + 1, 0);

          final dueToday = fees.payments.where((p) =>
            !p.isPaid && p.dueDate != null &&
            p.dueDate!.year == today.year &&
            p.dueDate!.month == today.month &&
            p.dueDate!.day == today.day
          ).toList();

          final dueThisWeek = fees.payments.where((p) =>
            !p.isPaid && p.dueDate != null &&
            p.dueDate!.isAfter(today) &&
            p.dueDate!.isBefore(weekEnd)
          ).toList();

          final dueThisMonth = fees.payments.where((p) =>
            !p.isPaid && p.dueDate != null &&
            p.dueDate!.isAfter(today) &&
            p.dueDate!.isBefore(monthEnd)
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReminderList(dueToday, 'No fees due today'),
              _buildReminderList(dueThisWeek, 'No fees due this week'),
              _buildReminderList(dueThisMonth, 'No fees due this month'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReminderList(List payments, String emptyMessage) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      child: const Icon(Icons.notifications, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(payment.userName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Due: ${payment.dueDate != null ? dateFormat.format(payment.dueDate!) : '-'}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${payment.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final msg = 'Hi, this is a reminder that your gym fee of ₹${payment.amount.toStringAsFixed(0)} is due on ${payment.dueDate != null ? dateFormat.format(payment.dueDate!) : 'soon'}. Please pay at the earliest. Thank you!';
                          final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/fees/record/${payment.userId}'),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Collect', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
