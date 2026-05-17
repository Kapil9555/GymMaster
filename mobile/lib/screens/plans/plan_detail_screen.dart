import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/plan_provider.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plans = context.read<PlanProvider>();
      if (plans.plans.isEmpty) plans.fetchAllPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Details')),
      body: Consumer<PlanProvider>(
        builder: (context, provider, _) {
          final plan = provider.plans.where((p) => p.id == widget.planId).firstOrNull;
          if (plan == null) {
            return const Center(child: Text('Plan not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.card_membership, color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(plan.planName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _priceBox('Monthly', '₹${plan.monthlyPlanAmount ?? '-'}'),
                          Container(width: 1, height: 40, color: Colors.white30),
                          _priceBox('Yearly', '₹${plan.yearlyPlanAmount ?? '-'}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amenities
                const Text('Included Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...plan.amenities.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a.key, style: const TextStyle(fontSize: 15))),
                      Text(a.value, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _priceBox(String label, String price) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        Text(price, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
