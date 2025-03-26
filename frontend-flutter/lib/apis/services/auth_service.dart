import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;

  // Save token securely
  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: "jwt_token", value: token);
  }

  // Retrieve token
  Future<String?> getToken() async {
    _token = await _storage.read(key: "jwt_token");
    return _token;
  }

  // Remove token (logout)
  Future<void> removeToken() async {
    _token = null;
    await _storage.delete(key: "jwt_token");
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
      var response = await _apiService.post("auth/signin", {
        "email": email,
        "password": password,
      });

      if (response != null && response["data"]["accessToken"] != null) {
        await saveToken(response["data"]["accessToken"]);
      }

      return response;
    }

  // Register
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
      final response = await _apiService.post("auth/signup", {
        "username": username,
        "email": email,
        "password": password,
        "fmcToken": ''
      });

      return response;
  }

  // Check password
  Future<Map<String, dynamic>> checkPassword(String password) async {
      final response = await _apiService.post("auth/check-password", {
        "password": password,
      });

      return response;
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
  }

}