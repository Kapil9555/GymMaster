import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_master/models/user_model.dart';
import 'package:gym_master/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userData = prefs.getString('user');
      if (_token != null && _token!.isNotEmpty && userData != null && userData.isNotEmpty) {
        try {
          final decoded = jsonDecode(userData);
          if (decoded is Map<String, dynamic>) {
            _user = User.fromJson(decoded);
          } else {
            await _clearStorage();
          }
        } catch (_) {
          await _clearStorage();
        }
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        _token = data['token']?.toString();
        final userJson = data['user'];
        if (_token == null || _token!.isEmpty || userJson is! Map) {
          _error = 'Invalid response from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _user = User.fromJson(Map<String, dynamic>.from(userJson));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _extractMessage(data) ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(userData);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _extractMessage(data) ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email, newPassword);
      final data = response.data;
      final success = data is Map && data['success'] == true;
      if (!success) {
        _error = _extractMessage(data) ?? 'Failed to reset password';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearStorage();
    notifyListeners();
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return null;
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      // Prefer the server-supplied message.
      final serverMsg = _extractMessage(e.response?.data);
      if (serverMsg != null) return serverMsg;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Connection timed out. Please check your internet and try again.';
        case DioExceptionType.connectionError:
          return 'Unable to reach the server. Please check your internet connection.';
        case DioExceptionType.badCertificate:
          return 'Secure connection failed. Please try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          return 'Server error${code != null ? ' ($code)' : ''}. Please try again.';
        case DioExceptionType.unknown:
          return 'Something went wrong. Please try again.';
      }
    }
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Something went wrong. Please try again.';
  }
}
