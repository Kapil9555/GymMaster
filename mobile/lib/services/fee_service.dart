import 'package:dio/dio.dart';
import 'package:gym_master/config/constants.dart';
import 'package:gym_master/services/api_client.dart';

class FeeService {
  final ApiClient _api = ApiClient();

  Future<Response> createPayment(Map<String, dynamic> data) {
    return _api.post(ApiConstants.createPayment, data: data);
  }

  Future<Response> markPaid(String id) {
    return _api.put('${ApiConstants.markPaid}/$id');
  }

  Future<Response> markUnpaid(String id) {
    return _api.put('${ApiConstants.markUnpaid}/$id');
  }

  Future<Response> updatePayment(String id, Map<String, dynamic> data) {
    return _api.put('${ApiConstants.updatePayment}/$id', data: data);
  }

  Future<Response> getPayments(String userId) {
    return _api.get('${ApiConstants.getPayments}/$userId');
  }

  Future<Response> getAllPayments() {
    return _api.get(ApiConstants.allPayments);
  }

  Future<Response> getOverdueMembers() {
    return _api.get(ApiConstants.overdueMembers);
  }

  Future<Response> getFeeSummary() {
    return _api.get(ApiConstants.feeSummary);
  }

  Future<Response> getPaymentReminders() {
    return _api.get(ApiConstants.paymentReminders);
  }
}
