import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String memberId;
  const PaymentHistoryScreen({super.key, required this.memberId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().fetchMemberPayments(widget.memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: Consumer<FeeProvider>(
        builder: (context, fees, _) {
          if (fees.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (fees.memberPayments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No payment history', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          // Summary at top
          final totalPaid = fees.memberPayments.where((p) => p.isPaid).fold(0.0, (sum, p) => sum + p.amount);
          final totalDue = fees.memberPayments.where((p) => !p.isPaid).fold(0.0, (sum, p) => sum + p.amount);

          return Column(
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Total Paid', '₹${totalPaid.toStringAsFixed(0)}', AppColors.success),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _summaryItem('Total Due', '₹${totalDue.toStringAsFixed(0)}', AppColors.danger),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _summaryItem('Records', '${fees.memberPayments.length}', AppColors.primary),
                  ],
                ),
              ),

              // Payment List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: fees.memberPayments.length,
                  itemBuilder: (context, index) {
                    final payment = fees.memberPayments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: payment.isPaid ? AppColors.success : AppColors.danger,
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (payment.isPaid ? AppColors.success : AppColors.danger).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    payment.isPaid ? Icons.check_circle : Icons.pending,
                                    color: payment.isPaid ? AppColors.success : AppColors.danger,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${payment.amount.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      if (payment.month != null)
                                        Text(payment.month!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (payment.isPaid ? AppColors.success : AppColors.danger).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        payment.isPaid ? 'PAID' : 'DUE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: payment.isPaid ? AppColors.success : AppColors.danger,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!payment.isPaid)
                                      InkWell(
                                        onTap: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Mark as Paid?'),
                                              content: Text('Confirm payment of ₹${payment.amount.toStringAsFixed(0)}?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: const Text('Confirm'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true && payment.id != null) {
                                            await context.read<FeeProvider>().markAsPaid(payment.id!);
                                            if (mounted) {
                                              context.read<FeeProvider>().fetchMemberPayments(widget.memberId);
                                            }
                                          }
                                        },
                                        child: const Text('Mark Paid', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Details Row
                            Row(
                              children: [
                                _detailChip(Icons.payment, payment.paymentMethod.toUpperCase()),
                                const SizedBox(width: 8),
                                if (payment.paymentDate != null)
                                  _detailChip(Icons.calendar_today, dateFormat.format(payment.paymentDate!)),
                                if (payment.coverFrom != null && payment.coverTo != null) ...[
                                  const SizedBox(width: 8),
                                  _detailChip(Icons.date_range, '${payment.months ?? 1}M'),
                                ],
                              ],
                            ),
                            if (payment.remarks != null && payment.remarks!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.notes, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(payment.remarks!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
