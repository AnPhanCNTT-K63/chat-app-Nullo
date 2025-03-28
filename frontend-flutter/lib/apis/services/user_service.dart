import 'package:app_chat_nullo/apis/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> updateAccount(String username, String email, String password, String fcmToken) async {
    Map<String, dynamic> data = {};

      if (password.isNotEmpty)
        data["password"] = password;
      if (username.isNotEmpty)
        data["username"] = username;
      if (email.isNotEmpty)
        data["email"] = email;
      if (fcmToken.isNotEmpty)
        data["fcmToken"] = fcmToken;

      var response = await _apiService.patch("user/update-account", data);

      return response;
  }

  Future<Map<String, dynamic>> updateProfile(String firstName, String lastName, String phone, String birthday) async {

    Map<String, dynamic> data = {};

    if (firstName.isNotEmpty)
      data["firstName"] = firstName;
    if (lastName.isNotEmpty)
      data["lastName"] = lastName;
    if (phone.isNotEmpty)
      data["phone"] = phone;
    if (birthday.isNotEmpty)
      data["birthday"] = birthday;

    var response = await _apiService.patch("user/update-profile", data);

    return response;
  }

  Future<Map<String, dynamic>> getProfile(String id) async {
    var response = await _apiService.get("user/$id");

    return response;
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    var response = await _apiService.get("user");

    return response;
  }

}