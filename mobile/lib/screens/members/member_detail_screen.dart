import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:intl/intl.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchMember(widget.memberId);
      context.read<FeeProvider>().fetchMemberPayments(widget.memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/members/${widget.memberId}/edit'),
          ),
        ],
      ),
      body: Consumer2<MemberProvider, FeeProvider>(
        builder: (context, memberProv, feeProv, _) {
          if (memberProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final member = memberProv.selectedMember;
          if (member == null) {
            return const Center(child: Text('Member not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: member.profilePic != null && member.profilePic!.isNotEmpty
                            ? NetworkImage(member.profilePic!)
                            : null,
                        child: member.profilePic == null || member.profilePic!.isEmpty
                            ? Text(member.initials, style: const TextStyle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(member.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('M ID: ${member.membershipId ?? member.id?.substring(member.id!.length - 4) ?? '-'}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: member.isActive ? AppColors.success : AppColors.danger,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(member.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickAction(Icons.phone, 'Call', () async {
                            final uri = Uri.parse('tel:${member.contact}');
                            if (await canLaunchUrl(uri)) await launchUrl(uri);
                          }),
                          _quickAction(Icons.chat, 'WhatsApp', () async {
                            final uri = Uri.parse('https://wa.me/91${member.contact}');
                            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }),
                          _quickAction(Icons.payment, 'Pay Fee', () {
                            context.push('/fees/record/${member.id}');
                          }),
                          _quickAction(Icons.history, 'History', () {
                            context.push('/fees/history/${member.id}');
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Membership Info
                      _infoCard('Membership Details', [
                        _infoRow('Plan Expiry', member.membershipEnd != null ? dateFormat.format(member.membershipEnd!) : 'N/A'),
                        _infoRow('Membership Start', member.membershipStart != null ? dateFormat.format(member.membershipStart!) : 'N/A'),
                        _infoRow('Fee Amount', '₹${member.feeAmount?.toStringAsFixed(0) ?? '0'}'),
                        _infoRow('Status', member.status.toUpperCase()),
                      ]),
                      const SizedBox(height: 12),

                      // Personal Info
                      _infoCard('Personal Information', [
                        _infoRow('Email', member.email),
                        _infoRow('Contact', '+91 ${member.contact}'),
                        _infoRow('Gender', member.gender?.toUpperCase() ?? '-'),
                        _infoRow('Age', '${member.age ?? '-'}'),
                        _infoRow('City', member.city ?? '-'),
                        _infoRow('Address', member.address ?? '-'),
                        _infoRow('Emergency Contact', member.emergencyContact ?? '-'),
                        _infoRow('Blood Group', member.bloodGroup ?? '-'),
                      ]),
                      const SizedBox(height: 12),

                      // Body Measurements
                      _infoCard('Body Measurements', [
                        _infoRow('Weight', '${member.weight ?? '-'} kg'),
                        _infoRow('Height', '${member.height ?? '-'} cm'),
                      ]),
                      const SizedBox(height: 12),

                      // Payment History
                      const Text('Payment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (feeProv.memberPayments.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No payments recorded', style: TextStyle(color: AppColors.textSecondary)),
                        ))
                      else
                        ...feeProv.memberPayments.take(5).map((payment) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: payment.isPaid ? AppColors.success.withOpacity(0.3) : AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                payment.isPaid ? Icons.check_circle : Icons.pending,
                                color: payment.isPaid ? AppColors.success : AppColors.danger,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('₹${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(payment.month ?? (payment.paymentDate != null ? dateFormat.format(payment.paymentDate!) : '-'),
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Text(
                                payment.isPaid ? 'PAID' : 'DUE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: payment.isPaid ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        )),
                      if (feeProv.memberPayments.length > 5)
                        TextButton(
                          onPressed: () => context.push('/fees/history/${member.id}'),
                          child: const Text('View All Payments →'),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
