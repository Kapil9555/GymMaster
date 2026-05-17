import 'package:flutter/material.dart';
import 'package:gym_master/models/user_model.dart';
import 'package:gym_master/services/member_service.dart';

class MemberProvider extends ChangeNotifier {
  final MemberService _memberService = MemberService();

  List<User> _members = [];
  List<User> _filteredMembers = [];
  User? _selectedMember;
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all';
  String _searchQuery = '';

  List<User> get members => _filteredMembers.isEmpty && _searchQuery.isEmpty && _filterStatus == 'all' 
      ? _members 
      : _filteredMembers;
  User? get selectedMember => _selectedMember;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  int get totalMembers => _members.length;
  int get activeMembers => _members.where((m) => m.status == 'active').length;
  int get inactiveMembers => _members.where((m) => m.status == 'inactive').length;
  int get expiredMembers => _members.where((m) => m.status == 'expired').length;
  int get blockedMembers => _members.where((m) => m.status == 'blocked').length;

  List<User> get expiringIn3Days => _members.where((m) {
    final days = m.daysUntilExpiry;
    return days >= 0 && days <= 3 && m.isActive;
  }).toList();

  List<User> get expiringIn7Days => _members.where((m) {
    final days = m.daysUntilExpiry;
    return days >= 4 && days <= 7 && m.isActive;
  }).toList();

  List<User> get expiringIn15Days => _members.where((m) {
    final days = m.daysUntilExpiry;
    return days >= 8 && days <= 15 && m.isActive;
  }).toList();

  List<User> get todayBirthdays {
    return _members.where((m) {
      // Would check DOB month/day match
      return false;
    }).toList();
  }

  Future<void> fetchAllMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _memberService.getAllMembers();
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['members'] ?? response.data['data'] ?? [];
        _members = data.map((json) => User.fromJson(json)).toList();
        _applyFilters();
      } else {
        _error = response.data['message'] ?? 'Failed to load members';
      }
    } catch (e) {
      _error = 'Failed to load members';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMember(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _memberService.getMember(id);
      if (response.data['success'] == true) {
        _selectedMember = User.fromJson(response.data['member'] ?? response.data['data']);
      }
    } catch (e) {
      _error = 'Failed to load member details';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMember(Map<String, dynamic> data, {String? imagePath}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _memberService.addMember(data, imagePath: imagePath);
      if (response.data['success'] == true) {
        await fetchAllMembers();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to add member';
    } catch (e) {
      _error = 'Failed to add member';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateMember(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _memberService.updateMember(id, data);
      if (response.data['success'] == true) {
        await fetchAllMembers();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update member';
    } catch (e) {
      _error = 'Failed to update member';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteMember(String id) async {
    try {
      final response = await _memberService.deleteMember(id);
      if (response.data['success'] == true) {
        _members.removeWhere((m) => m.id == id);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete member';
    }
    return false;
  }

  Future<bool> updateMemberStatus(String id, String status) async {
    try {
      final response = await _memberService.updateMemberStatus(id, status);
      if (response.data['success'] == true) {
        final index = _members.indexWhere((m) => m.id == id);
        if (index != -1) {
          _members[index] = _members[index].copyWith(status: status);
          _applyFilters();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Failed to update status';
    }
    return false;
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMembers = _members.where((member) {
      final matchesStatus = _filterStatus == 'all' || member.status == _filterStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.contact.contains(_searchQuery) ||
          (member.membershipId?.contains(_searchQuery) ?? false);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
