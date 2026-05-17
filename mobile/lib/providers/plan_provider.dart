import 'package:flutter/material.dart';
import 'package:gym_master/models/plan_model.dart';
import 'package:gym_master/services/plan_service.dart';

class PlanProvider extends ChangeNotifier {
  final PlanService _planService = PlanService();

  List<Plan> _plans = [];
  Plan? _selectedPlan;
  bool _isLoading = false;
  String? _error;

  List<Plan> get plans => _plans;
  Plan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPlans => _plans.length;

  Future<void> fetchAllPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _planService.getAllPlans();
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['plans'] ?? response.data['data'] ?? [];
        _plans = data.map((json) => Plan.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Failed to load plans';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPlan(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _planService.createPlan(data);
      if (response.data['success'] == true) {
        await fetchAllPlans();
        return true;
      }
      _error = response.data['message'];
    } catch (e) {
      _error = 'Failed to create plan';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updatePlan(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _planService.updatePlan(id, data);
      if (response.data['success'] == true) {
        await fetchAllPlans();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update plan';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deletePlan(String id) async {
    try {
      final response = await _planService.deletePlan(id);
      if (response.data['success'] == true) {
        _plans.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete plan';
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
