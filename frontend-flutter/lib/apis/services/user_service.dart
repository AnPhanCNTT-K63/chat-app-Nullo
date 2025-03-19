import 'package:app_chat_nullo/apis/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> updateAccount(String username, String email, String password) async {
      final data = {
        "username": username,
        "email": email,
      };
      if (password.isNotEmpty) {
        data["password"] = password;
      }
      var response = await _apiService.patch("user/update-account", data);

      return response;
  }

  Future<Map<String, dynamic>> updateProfile(String firstName, String lastName, String phone, String birthday) async {
    var response = await _apiService.patch("user/update-profile", {
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "birthday": birthday,
    });

    return response;
  }

  Future<Map<String, dynamic>> getProfile(String id) async {
    var response = await _apiService.get("user/$id");

    return response;
  }
}