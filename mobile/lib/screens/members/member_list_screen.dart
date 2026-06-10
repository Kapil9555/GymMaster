import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/models/user_model.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:intl/intl.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  String _selectedPlan = 'All Plans';
  String _selectedBatch = 'Select Batch';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchAllMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => context.read<MemberProvider>().search(q),
                decoration: InputDecoration(
                  hintText: 'Search for "MembershipId"',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<MemberProvider>().search('');
                          },
                        )
                      : const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterDropdown(
                    value: context.watch<MemberProvider>().filterStatus == 'all' 
                        ? 'All Member' 
                        : context.watch<MemberProvider>().filterStatus,
                    items: ['All Member', 'active', 'inactive', 'expired', 'blocked'],
                    onChanged: (v) {
                      context.read<MemberProvider>().setFilter(
                        v == 'All Member' ? 'all' : v!,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _filterDropdown(
                    value: _selectedPlan,
                    items: ['All Plans', 'Monthly', 'Yearly', 'Quarterly'],
                    onChanged: (v) => setState(() => _selectedPlan = v!),
                  ),
                  const SizedBox(width: 8),
                  _filterDropdown(
                    value: _selectedBatch,
                    items: ['Select Batch', 'Morning', 'Evening', 'Night'],
                    onChanged: (v) => setState(() => _selectedBatch = v!),
                  ),
                ],
              ),
            ),
          ),

          // Member List
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(provider.error!, style: const TextStyle(color: AppColors.danger)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => provider.fetchAllMembers(), child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                if (provider.members.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text('No members found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.fetchAllMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.members.length,
                    itemBuilder: (context, index) {
                      return _MemberCard(member: provider.members[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final User member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isExpired = member.isMembershipExpired;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
        border: Border(
          right: BorderSide(
            color: isExpired ? AppColors.danger : AppColors.success,
            width: 5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Top Row: Avatar + Info + Delete
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary,
                  backgroundImage: member.profilePic != null && member.profilePic!.isNotEmpty
                      ? NetworkImage(member.profilePic!)
                      : null,
                  child: member.profilePic == null || member.profilePic!.isEmpty
                      ? Text(
                          member.initials,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + M ID
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Name:', style: TextStyle(fontSize: 12, color: AppColors.textTeal)),
                                Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('M ID', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(
                                member.membershipId ?? _shortId(member.id) ?? '-',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showDeleteDialog(context, member),
                            child: const Icon(Icons.delete_outline, color: AppColors.primaryDark, size: 22),
                          ),
                        ],
                      ),

                      // Mobile
                      const SizedBox(height: 4),
                      Text('Mobile:', style: TextStyle(fontSize: 12, color: AppColors.textTeal)),
                      Text('+91 - ${member.contact}', style: const TextStyle(fontSize: 14)),

                      // Plan Expiry + Due Amount
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Plan Expiry:', style: TextStyle(fontSize: 12, color: AppColors.textTeal)),
                                Text(
                                  member.membershipEnd != null ? dateFormat.format(member.membershipEnd!) : 'N/A',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isExpired ? AppColors.danger : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Due Amount:', style: TextStyle(fontSize: 12, color: AppColors.textTeal)),
                              Text(
                                '${member.feeAmount?.toStringAsFixed(0) ?? '0'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: (member.feeAmount ?? 0) > 0 ? AppColors.danger : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionIcon(Icons.badge_outlined, 'ID Card', () {
                  final id = member.id;
                  if (id != null && id.isNotEmpty) context.push('/members/$id');
                }),
                _actionIcon(Icons.phone, 'Call', () async {
                  final uri = Uri.parse('tel:${member.contact}');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }),
                _actionIcon(Icons.chat_bubble_outline, 'Whatsapp', () async {
                  final uri = Uri.parse('https://wa.me/91${member.contact}');
                  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                }),
                _actionIcon(Icons.back_hand_outlined, 'Attendance', () {
                  // Mark attendance for this member
                }),
                _actionIcon(Icons.grid_view, 'Renew Plan', () {
                  final id = member.id;
                  if (id != null && id.isNotEmpty) context.push('/fees/record/$id');
                }),
                _actionIcon(Icons.block, 'Block', () {
                  final id = member.id;
                  if (id == null || id.isEmpty) return;
                  context.read<MemberProvider>().updateMemberStatus(
                    id,
                    member.isBlocked ? 'active' : 'blocked',
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.primaryDark)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, User member) {
    final id = member.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member id missing'), backgroundColor: AppColors.danger),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MemberProvider>().deleteMember(id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  static String? _shortId(String? id, [int n = 3]) {
    if (id == null || id.isEmpty) return null;
    return id.length <= n ? id : id.substring(id.length - n);
  }
}
