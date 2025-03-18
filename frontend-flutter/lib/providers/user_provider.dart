import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? _token;
  String? _username;
  String? _email;

  String? get token => _token;
  String? get username => _username;
  String? get email => _email;

  UserProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await loadUserData();
  }

  Future<void> loadUserData() async {
    _token = await secureStorage.read(key: "jwt_token");
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      _username = decodedToken["username"];
      _email = decodedToken["email"];
    } else {
      _token = null;
      _username = null;
      _email = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await secureStorage.delete(key: "jwt_token");
    _token = null;
    _username = null;
    _email = null;
    notifyListeners();
  }
}
