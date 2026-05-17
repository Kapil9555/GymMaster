import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';

class EditMemberScreen extends StatefulWidget {
  final String memberId;
  const EditMemberScreen({super.key, required this.memberId});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _feeAmountCtrl = TextEditingController();
  String _gender = 'male';
  String _status = 'active';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MemberProvider>().fetchMember(widget.memberId);
      _populateFields();
    });
  }

  void _populateFields() {
    final member = context.read<MemberProvider>().selectedMember;
    if (member != null && !_loaded) {
      _nameCtrl.text = member.name;
      _contactCtrl.text = member.contact;
      _cityCtrl.text = member.city ?? '';
      _addressCtrl.text = member.address ?? '';
      _ageCtrl.text = '${member.age ?? ''}';
      _weightCtrl.text = '${member.weight ?? ''}';
      _heightCtrl.text = '${member.height ?? ''}';
      _feeAmountCtrl.text = '${member.feeAmount ?? ''}';
      _gender = member.gender ?? 'male';
      _status = member.status;
      _loaded = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _feeAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'contact': _contactCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'gender': _gender,
      'age': int.tryParse(_ageCtrl.text) ?? 0,
      'weight': double.tryParse(_weightCtrl.text) ?? 0,
      'height': double.tryParse(_heightCtrl.text) ?? 0,
      'feeAmount': double.tryParse(_feeAmountCtrl.text) ?? 0,
      'status': _status,
    };

    final success = await context.read<MemberProvider>().updateMember(widget.memberId, data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member updated!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member')),
      body: Consumer<MemberProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !_loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Contact *'),
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
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _feeAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fee Amount (₹)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['active', 'inactive', 'expired', 'blocked']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleUpdate,
                      child: provider.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          : const Text('Update Member'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
