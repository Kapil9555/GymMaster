import 'package:dio/dio.dart';
import 'package:gym_master/config/constants.dart';
import 'package:gym_master/services/api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<Response> login(String email, String password) {
    return _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) {
    return _api.post(ApiConstants.register, data: userData);
  }

  Future<Response> forgotPassword(String email, String newPassword) {
    return _api.post(ApiConstants.forgotPassword, data: {
      'email': email,
      'newPassword': newPassword,
    });
  }

  Future<Response> updateProfile(Map<String, dynamic> data) {
    return _api.put(ApiConstants.userProfile, data: data);
  }

  Future<Response> getTotalUsers() {
    return _api.get(ApiConstants.totalUsers);
  }

  Future<Response> getAllUsers() {
    return _api.get(ApiConstants.allUsers);
  }
}
