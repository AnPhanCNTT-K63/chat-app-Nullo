import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiService apiService = ApiService();
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
    try {
      var response = await apiService.postRequest("auth/signin", {
        "email": email,
        "password": password,
      });

      if (response != null && response["accessToken"] != null) {
        await saveToken(response["accessToken"]);
      }

      return response; // Return full response
    } catch (e) {
      return {"error": "Login failed: $e"}; // Return error message
    }
  }


  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await apiService.postRequest("auth/signup", {
        "username": username,
        "email": email,
        "password": password,
      });

      return response; // Return response for error handling
    } catch (e) {
      return {"error": "Registration failed: $e"};
    }
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
  }

  // Attach token to API requests
  Future<Dio> getAuthorizedDio() async {
    Dio dio = apiService.dio;
    String? token = await getToken();
    if (token != null) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }
    return dio;
  }
}