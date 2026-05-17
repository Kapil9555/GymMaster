import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'dart:io';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _feeAmountCtrl = TextEditingController();

  String _gender = 'male';
  String _bloodGroup = 'O+';
  String? _imagePath;
  DateTime? _membershipStart;
  DateTime? _membershipEnd;

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _contactCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _feeAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _membershipStart = date;
        } else {
          _membershipEnd = date;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'contact': _contactCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'gender': _gender,
      'age': int.tryParse(_ageCtrl.text) ?? 0,
      'bloodGroup': _bloodGroup,
      'emergencyContact': _emergencyCtrl.text.trim(),
      'weight': double.tryParse(_weightCtrl.text) ?? 0,
      'height': double.tryParse(_heightCtrl.text) ?? 0,
      'feeAmount': double.tryParse(_feeAmountCtrl.text) ?? 0,
      if (_membershipStart != null) 'membershipStart': _membershipStart!.toIso8601String(),
      if (_membershipEnd != null) 'membershipEnd': _membershipEnd!.toIso8601String(),
    };

    final success = await context.read<MemberProvider>().addMember(data, imagePath: _imagePath);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully!'), backgroundColor: AppColors.success),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<MemberProvider>().error ?? 'Failed to add member'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null
                        ? const Icon(Icons.camera_alt, size: 32, color: AppColors.primary)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Tap to add photo', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
              const SizedBox(height: 24),

              _sectionTitle('Personal Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password *', prefixIcon: Icon(Icons.lock)),
                validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Number *', prefixIcon: Icon(Icons.phone)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['male', 'female', 'other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g.capitalize())))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: const InputDecoration(labelText: 'Blood Group'),
                      items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 12),
              TextFormField(controller: _emergencyCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Emergency Contact')),

              const SizedBox(height: 24),
              _sectionTitle('Body Measurements'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)')),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('Membership Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feeAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fee Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _datePickerField('Start Date', _membershipStart, () => _selectDate(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datePickerField('End Date', _membershipEnd, () => _selectDate(false)),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Consumer<MemberProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      icon: provider.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.person_add),
                      label: const Text('Add Member'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary));
  }

  Widget _datePickerField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(
          date != null ? '${date.day}/${date.month}/${date.year}' : 'Select',
          style: TextStyle(color: date != null ? AppColors.textPrimary : AppColors.textSecondary),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
