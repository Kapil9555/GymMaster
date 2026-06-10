import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchAllMembers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy');
    final attendance = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
            onPressed: () {
              // QR scanner for attendance
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Scanner coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date & Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Date Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        attendance.setSelectedDate(attendance.selectedDate.subtract(const Duration(days: 1)));
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: attendance.selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) attendance.setSelectedDate(date);
                      },
                      child: Text(
                        dateFormat.format(attendance.selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        final nextDay = attendance.selectedDate.add(const Duration(days: 1));
                        if (!nextDay.isAfter(DateTime.now())) {
                          attendance.setSelectedDate(nextDay);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Today's Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Present Today: ${attendance.todayCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => context.read<MemberProvider>().search(q),
              decoration: InputDecoration(
                hintText: 'Search member to mark attendance...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Member List for Attendance
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, members, _) {
                if (members.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final activeMembers = members.members.where((m) => m.isActive).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: activeMembers.length,
                  itemBuilder: (context, index) {
                    final member = activeMembers[index];
                    final isPresent = attendance.attendanceList.any((a) =>
                      a.userId == member.id &&
                      a.date.year == attendance.selectedDate.year &&
                      a.date.month == attendance.selectedDate.month &&
                      a.date.day == attendance.selectedDate.day
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: isPresent ? AppColors.success : AppColors.primary.withOpacity(0.1),
                          child: isPresent
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : Text(member.initials, style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(member.contact, style: const TextStyle(fontSize: 12)),
                        trailing: isPresent
                            ? const Chip(
                                label: Text('Present', style: TextStyle(color: Colors.white, fontSize: 11)),
                                backgroundColor: AppColors.success,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  final id = member.id;
                                  if (id == null || id.isEmpty) return;
                                  attendance.markAttendance(id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${member.name} marked present!'),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Mark', style: TextStyle(fontSize: 13)),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
