import 'package:dio/dio.dart';
import 'package:gym_master/config/constants.dart';
import 'package:gym_master/services/api_client.dart';

class PlanService {
  final ApiClient _api = ApiClient();

  Future<Response> createPlan(Map<String, dynamic> data) {
    return _api.post(ApiConstants.createPlan, data: data);
  }

  Future<Response> updatePlan(String id, Map<String, dynamic> data) {
    return _api.put('${ApiConstants.updatePlan}/$id', data: data);
  }

  Future<Response> deletePlan(String id) {
    return _api.delete('${ApiConstants.deletePlan}/$id');
  }

  Future<Response> getAllPlans() {
    return _api.get(ApiConstants.allPlans);
  }

  Future<Response> getPlan(String id) {
    return _api.get('${ApiConstants.getPlan}/$id');
  }

  Future<Response> getTotalPlans() {
    return _api.get(ApiConstants.totalPlans);
  }
}
