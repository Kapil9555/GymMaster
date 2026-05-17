import 'package:flutter/material.dart';
import 'package:gym_master/providers/member_provider.dart';
import 'package:gym_master/providers/fee_provider.dart';
import 'package:gym_master/providers/plan_provider.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard(
    MemberProvider memberProvider,
    FeeProvider feeProvider,
    PlanProvider planProvider,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      memberProvider.fetchAllMembers(),
      feeProvider.fetchAllPayments(),
      feeProvider.fetchFeeSummary(),
      planProvider.fetchAllPlans(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
