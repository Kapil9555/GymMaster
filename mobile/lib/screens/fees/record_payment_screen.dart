import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/models/user_model.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:intl/intl.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String? memberId;
  const RecordPaymentScreen({super.key, this.memberId});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _receiptCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _paymentMethod = 'cash';
  String _discountType = 'fixed';
  int _months = 1;
  DateTime _coverFrom = DateTime.now();
  DateTime? _coverTo;
  DateTime? _dueDate;
  User? _selectedMember;
  bool _isPaid = true;
  bool _showMemberSearch = false;

  final _paymentMethods = [
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.money},
    {'value': 'upi', 'label': 'UPI', 'icon': Icons.qr_code},
    {'value': 'card', 'label': 'Card', 'icon': Icons.credit_card},
    {'value': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchAllMembers();
      if (widget.memberId != null) {
        _loadMember(widget.memberId!);
      }
    });
    _updateCoverTo();
  }

  void _loadMember(String id) async {
    await context.read<MemberProvider>().fetchMember(id);
    final member = context.read<MemberProvider>().selectedMember;
    if (member != null) {
      setState(() {
        _selectedMember = member;
        _amountCtrl.text = '${member.feeAmount?.toStringAsFixed(0) ?? ''}';
      });
    }
  }

  void _updateCoverTo() {
    _coverTo = DateTime(_coverFrom.year, _coverFrom.month + _months, _coverFrom.day);
    _dueDate = _coverFrom;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    _receiptCtrl.dispose();
    _discountCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(String field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (field == 'from') {
          _coverFrom = date;
          _updateCoverTo();
        } else if (field == 'to') {
          _coverTo = date;
        } else if (field == 'due') {
          _dueDate = date;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;

    double finalAmount = amount;
    if (discount > 0) {
      if (_discountType == 'percentage') {
        finalAmount = amount - (amount * discount / 100);
      } else {
        finalAmount = amount - discount;
      }
    }

    final data = {
      'user': _selectedMember!.id,
      'amount': finalAmount,
      'dueDate': _dueDate?.toIso8601String() ?? _coverFrom.toIso8601String(),
      'isPaid': _isPaid,
      'paymentMethod': _paymentMethod,
      'months': _months,
      'coverFrom': _coverFrom.toIso8601String(),
      'coverTo': _coverTo?.toIso8601String(),
      'remarks': _remarksCtrl.text.trim(),
      'receiptNumber': _receiptCtrl.text.trim(),
      if (_isPaid) 'paymentDate': DateTime.now().toIso8601String(),
      if (discount > 0) 'discount': discount,
      if (discount > 0) 'discountType': _discountType,
    };

    final success = await context.read<FeeProvider>().createPayment(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPaid ? 'Payment recorded successfully!' : 'Fee entry created!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<FeeProvider>().error ?? 'Failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Member Selection
              _sectionTitle('Select Member'),
              const SizedBox(height: 8),
              if (_selectedMember != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(_selectedMember!.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedMember!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('+91 ${_selectedMember!.contact}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.danger),
                        onPressed: () => setState(() {
                          _selectedMember = null;
                          _showMemberSearch = true;
                        }),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _searchCtrl,
                  onTap: () => setState(() => _showMemberSearch = true),
                  onChanged: (q) => context.read<MemberProvider>().search(q),
                  decoration: const InputDecoration(
                    hintText: 'Search member by name, ID, or phone...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                if (_showMemberSearch)
                  Consumer<MemberProvider>(
                    builder: (context, provider, _) {
                      final filtered = provider.members.take(5).toList();
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final m = filtered[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(m.initials, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              title: Text(m.name),
                              subtitle: Text(m.contact, style: const TextStyle(fontSize: 12)),
                              onTap: () {
                                setState(() {
                                  _selectedMember = m;
                                  _showMemberSearch = false;
                                  _searchCtrl.clear();
                                  _amountCtrl.text = '${m.feeAmount?.toStringAsFixed(0) ?? ''}';
                                });
                                context.read<MemberProvider>().search('');
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],

              const SizedBox(height: 24),

              // Amount
              _sectionTitle('Payment Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee, size: 28),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  if (double.tryParse(v) == null) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Discount
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Discount'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _discountType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(value: 'fixed', child: Text('₹')),
                        DropdownMenuItem(value: 'percentage', child: Text('%')),
                      ],
                      onChanged: (v) => setState(() => _discountType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Method
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _paymentMethods.map((method) {
                  final isSelected = _paymentMethod == method['value'];
                  return ChoiceChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(method['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(method['label'] as String),
                      ],
                    ),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                    onSelected: (selected) {
                      if (selected) setState(() => _paymentMethod = method['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Duration
              Row(
                children: [
                  const Text('Months: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  ...List.generate(6, (i) {
                    final m = i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        selected: _months == m,
                        label: Text('$m'),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _months == m ? Colors.white : AppColors.textPrimary),
                        onSelected: (selected) {
                          if (selected) setState(() {
                            _months = m;
                            _updateCoverTo();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Coverage Period
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate('from'),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'From'),
                        child: Text(dateFormat.format(_coverFrom)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate('to'),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'To'),
                        child: Text(_coverTo != null ? dateFormat.format(_coverTo!) : '-'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Status
              SwitchListTile(
                title: const Text('Mark as Paid'),
                subtitle: Text(_isPaid ? 'Payment received' : 'Create as pending'),
                value: _isPaid,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isPaid = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),

              // Receipt & Remarks
              TextFormField(
                controller: _receiptCtrl,
                decoration: const InputDecoration(labelText: 'Receipt Number', prefixIcon: Icon(Icons.receipt)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarksCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Remarks', prefixIcon: Icon(Icons.notes)),
              ),

              const SizedBox(height: 32),

              // Submit
              Consumer<FeeProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      icon: provider.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_isPaid ? Icons.check_circle : Icons.add_circle),
                      label: Text(_isPaid ? 'Record Payment' : 'Create Fee Entry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaid ? AppColors.success : AppColors.primary,
                      ),
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
}
