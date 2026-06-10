import 'package:dio/dio.dart';
import 'package:gym_master/config/constants.dart';
import 'package:gym_master/services/api_client.dart';

class MemberService {
  final ApiClient _api = ApiClient();

  Future<Response> addMember(Map<String, dynamic> data, {String? imagePath}) async {
    if (imagePath != null) {
      return _api.uploadFile(ApiConstants.addMember, imagePath, fields: data);
    }
    return _api.post(ApiConstants.addMember, data: data);
  }

  Future<Response> updateMember(String id, Map<String, dynamic> data) {
    return _api.put('${ApiConstants.updateMember}/$id', data: data);
  }

  Future<Response> deleteMember(String id) {
    return _api.delete('${ApiConstants.deleteMember}/$id');
  }

  Future<Response> getMember(String id) {
    return _api.get('${ApiConstants.getMember}/$id');
  }

  Future<Response> getAllMembers() {
    return _api.get(ApiConstants.allMembers);
  }

  Future<Response> searchMembers(String query) {
    return _api.get(ApiConstants.searchMembers, queryParameters: {'q': query});
  }

  Future<Response> updateMemberStatus(String id, String status) {
    return _api.put('${ApiConstants.updateMemberStatus}/$id', data: {'status': status});
  }

  Future<Response> updateProfilePic(String id, String imagePath) {
    return _api.uploadFile('${ApiConstants.updateProfilePic}/$id', imagePath);
  }

  Future<Response> getTotalMembers() {
    return _api.get(ApiConstants.totalMembers);
  }
}
