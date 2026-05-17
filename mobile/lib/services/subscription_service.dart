import 'package:dio/dio.dart';
import 'package:gym_master/config/constants.dart';
import 'package:gym_master/services/api_client.dart';

class SubscriptionService {
  final ApiClient _api = ApiClient();

  Future<Response> createSubscription(Map<String, dynamic> data) {
    return _api.post(ApiConstants.createSubscription, data: data);
  }

  Future<Response> updateSubscription(String id, Map<String, dynamic> data) {
    return _api.put('${ApiConstants.updateSubscription}/$id', data: data);
  }

  Future<Response> deleteSubscription(String id) {
    return _api.delete('${ApiConstants.deleteSubscription}/$id');
  }

  Future<Response> getAllSubscriptions() {
    return _api.get(ApiConstants.allSubscriptions);
  }

  Future<Response> getSubscription(String id) {
    return _api.get('${ApiConstants.getSubscription}/$id');
  }

  Future<Response> getTotalSubscriptions() {
    return _api.get(ApiConstants.totalSubscriptions);
  }
}
