import 'package:flutter/material.dart';
import 'package:gym_master/models/subscription_model.dart';
import 'package:gym_master/services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();

  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getAllSubscriptions();
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['subscriptions'] ?? response.data['data'] ?? [];
        _subscriptions = data.map((json) => Subscription.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Failed to load subscriptions';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final response = await _service.createSubscription(data);
      if (response.data['success'] == true) {
        await fetchAll();
        return true;
      }
    } catch (e) {
      _error = 'Failed to create subscription';
    }
    return false;
  }
}
