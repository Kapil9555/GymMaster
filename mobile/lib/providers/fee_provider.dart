import 'package:flutter/material.dart';
import 'package:gym_master/models/fee_model.dart';
import 'package:gym_master/services/fee_service.dart';

class FeeProvider extends ChangeNotifier {
  final FeeService _feeService = FeeService();

  List<FeePayment> _payments = [];
  List<FeePayment> _memberPayments = [];
  List<Map<String, dynamic>> _overdueMembers = [];
  List<Map<String, dynamic>> _reminders = [];
  FeeSummary? _summary;
  bool _isLoading = false;
  String? _error;

  List<FeePayment> get payments => _payments;
  List<FeePayment> get memberPayments => _memberPayments;
  List<Map<String, dynamic>> get overdueMembers => _overdueMembers;
  List<Map<String, dynamic>> get reminders => _reminders;
  FeeSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fee stats
  double get totalCollected => _payments.where((p) => p.isPaid).fold(0.0, (sum, p) => sum + p.amount);
  double get totalDue => _payments.where((p) => !p.isPaid).fold(0.0, (sum, p) => sum + p.amount);
  int get paidCount => _payments.where((p) => p.isPaid).length;
  int get unpaidCount => _payments.where((p) => !p.isPaid).length;
  int get overdueCount => _payments.where((p) => p.isOverdue).length;

  double get todayCollection {
    final today = DateTime.now();
    return _payments.where((p) => 
      p.isPaid && 
      p.paymentDate != null &&
      p.paymentDate!.year == today.year &&
      p.paymentDate!.month == today.month &&
      p.paymentDate!.day == today.day
    ).fold(0.0, (sum, p) => sum + p.amount);
  }

  double get monthlyCollection {
    final now = DateTime.now();
    return _payments.where((p) =>
      p.isPaid &&
      p.paymentDate != null &&
      p.paymentDate!.year == now.year &&
      p.paymentDate!.month == now.month
    ).fold(0.0, (sum, p) => sum + p.amount);
  }

  Map<String, double> get paymentMethodBreakdown {
    final breakdown = <String, double>{};
    for (final p in _payments.where((p) => p.isPaid)) {
      breakdown[p.paymentMethod] = (breakdown[p.paymentMethod] ?? 0) + p.amount;
    }
    return breakdown;
  }

  Future<void> fetchAllPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _feeService.getAllPayments();
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['payments'] ?? response.data['data'] ?? [];
        _payments = data.map((json) => FeePayment.fromJson(json)).toList();
      } else {
        _error = response.data['message'];
      }
    } catch (e) {
      _error = 'Failed to load payments';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMemberPayments(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _feeService.getPayments(userId);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['payments'] ?? response.data['data'] ?? [];
        _memberPayments = data.map((json) => FeePayment.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Failed to load payment history';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPayment(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _feeService.createPayment(data);
      if (response.data['success'] == true) {
        await fetchAllPayments();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to record payment';
    } catch (e) {
      _error = 'Failed to record payment';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> markAsPaid(String id) async {
    try {
      final response = await _feeService.markPaid(id);
      if (response.data['success'] == true) {
        final index = _payments.indexWhere((p) => p.id == id);
        if (index != -1) {
          _payments[index] = FeePayment(
            id: _payments[index].id,
            userId: _payments[index].userId,
            amount: _payments[index].amount,
            isPaid: true,
            paymentDate: DateTime.now(),
            paymentMethod: _payments[index].paymentMethod,
            dueDate: _payments[index].dueDate,
            month: _payments[index].month,
            months: _payments[index].months,
            coverFrom: _payments[index].coverFrom,
            coverTo: _payments[index].coverTo,
            remarks: _payments[index].remarks,
            receiptNumber: _payments[index].receiptNumber,
            collectedBy: _payments[index].collectedBy,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Failed to update payment';
    }
    return false;
  }

  Future<bool> markAsUnpaid(String id) async {
    try {
      final response = await _feeService.markUnpaid(id);
      if (response.data['success'] == true) {
        await fetchAllPayments();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update payment';
    }
    return false;
  }

  Future<void> fetchOverdueMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _feeService.getOverdueMembers();
      if (response.data['success'] == true) {
        _overdueMembers = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
    } catch (e) {
      _error = 'Failed to load overdue members';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFeeSummary() async {
    try {
      final response = await _feeService.getFeeSummary();
      if (response.data['success'] == true) {
        _summary = FeeSummary.fromJson(response.data['data'] ?? response.data);
      }
    } catch (e) {
      // Summary fetch failed silently
    }
    notifyListeners();
  }

  Future<void> fetchReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _feeService.getPaymentReminders();
      if (response.data['success'] == true) {
        _reminders = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
    } catch (e) {
      _error = 'Failed to load reminders';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
