import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/fee_provider.dart';

class OverdueMembersScreen extends StatefulWidget {
  const OverdueMembersScreen({super.key});

  @override
  State<OverdueMembersScreen> createState() => _OverdueMembersScreenState();
}

class _OverdueMembersScreenState extends State<OverdueMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().fetchOverdueMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overdue Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Send Bulk Reminders',
            onPressed: _sendBulkReminders,
          ),
        ],
      ),
      body: Consumer<FeeProvider>(
        builder: (context, fees, _) {
          if (fees.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use payments that are overdue
          final overduePayments = fees.payments.where((p) => p.isOverdue).toList()
            ..sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

          if (overduePayments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No overdue payments!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('All members are up to date', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.danger.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Total Overdue', '${overduePayments.length}', AppColors.danger),
                    _statItem(
                      'Total Due Amount',
                      '₹${overduePayments.fold(0.0, (sum, p) => sum + p.amount).toStringAsFixed(0)}',
                      AppColors.danger,
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await fees.fetchAllPayments();
                    await fees.fetchOverdueMembers();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: overduePayments.length,
                    itemBuilder: (context, index) {
                      final payment = overduePayments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.danger.withOpacity(0.1),
                                    child: const Icon(Icons.person, color: AppColors.danger),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.userName ?? 'Member',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          '${payment.daysOverdue} days overdue',
                                          style: const TextStyle(color: AppColors.danger, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${payment.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final uid = payment.userId;
                                        if (uid.isNotEmpty) context.push('/fees/record/$uid');
                                      },
                                      icon: const Icon(Icons.payment, size: 16),
                                      label: const Text('Collect', style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.success,
                                        side: const BorderSide(color: AppColors.success),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final msg = 'Hi, your gym fee of ₹${payment.amount.toStringAsFixed(0)} is overdue by ${payment.daysOverdue} days. Please pay at the earliest.';
                                        final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      icon: const Icon(Icons.chat, size: 16),
                                      label: const Text('Remind', style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.warning,
                                        side: const BorderSide(color: AppColors.warning),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        if (payment.id != null) {
                                          context.read<FeeProvider>().markAsPaid(payment.id!);
                                        }
                                      },
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(color: AppColors.primary),
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  void _sendBulkReminders() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Bulk Reminders'),
        content: const Text('Send WhatsApp reminders to all overdue members?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminders will be sent!'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Send All'),
          ),
        ],
      ),
    );
  }
}
