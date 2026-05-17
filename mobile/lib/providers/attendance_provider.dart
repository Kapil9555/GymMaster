import 'package:flutter/material.dart';
import 'package:gym_master/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _attendanceList = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Attendance> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  int get todayCount => _attendanceList.where((a) {
    final now = DateTime.now();
    return a.date.year == now.year && a.date.month == now.month && a.date.day == now.day;
  }).length;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> markAttendance(String userId) async {
    // Will be implemented when attendance endpoint is added to backend
    _attendanceList.add(Attendance(
      userId: userId,
      date: DateTime.now(),
      checkInTime: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
