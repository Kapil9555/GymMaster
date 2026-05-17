import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/plan_provider.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  final _yearlyCtrl = TextEditingController();

  final _amenities = <String, bool>{
    'waterStations': false,
    'lockerRooms': false,
    'wifiService': false,
    'cardioClass': false,
    'refreshment': false,
    'groupFitnessClasses': false,
    'personalTrainer': false,
    'specialEvents': false,
    'cafeOrLounge': false,
  };

  final _amenityLabels = {
    'waterStations': 'Water Stations',
    'lockerRooms': 'Locker Rooms',
    'wifiService': 'WiFi Service',
    'cardioClass': 'Cardio Class',
    'refreshment': 'Refreshments',
    'groupFitnessClasses': 'Group Fitness',
    'personalTrainer': 'Personal Trainer',
    'specialEvents': 'Special Events',
    'cafeOrLounge': 'Cafe/Lounge',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'planName': _nameCtrl.text.trim(),
      'monthlyPlanAmount': _monthlyCtrl.text.trim(),
      'yearlyPlanAmount': _yearlyCtrl.text.trim(),
    };

    for (final entry in _amenities.entries) {
      data[entry.key] = entry.value ? 'Yes' : 'No';
    }

    final success = await context.read<PlanProvider>().createPlan(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan created!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Plan Name *', prefixIcon: Icon(Icons.card_membership)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monthly Price (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearlyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Yearly Price (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              ..._amenities.entries.map((entry) {
                return SwitchListTile(
                  title: Text(_amenityLabels[entry.key] ?? entry.key),
                  value: entry.value,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _amenities[entry.key] = v),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
              const SizedBox(height: 24),
              Consumer<PlanProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      child: provider.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          : const Text('Create Plan'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
