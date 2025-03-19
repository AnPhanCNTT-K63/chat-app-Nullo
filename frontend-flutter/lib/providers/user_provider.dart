import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProvider with ChangeNotifier {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _token;
  String? _id;
  String? _username;
  String? _email;

  String? get token => _token;
  String? get id => _id;
  String? get username => _username;
  String? get email => _email;

  UserProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    _token = await _secureStorage.read(key: "jwt_token");
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      _id = decodedToken["_id"];
      _username = decodedToken["username"];
      _email = decodedToken["email"];
    } else {
      _token = null;
      _id = null;
      _username = null;
      _email = null;
    }
    notifyListeners();
  }

  Future<void> updateUser(String newUsername, String newEmail) async {
    _username = newUsername;
    _email = newEmail;

    await _secureStorage.write(key: "username", value: newUsername);
    await _secureStorage.write(key: "email", value: newEmail);

    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: "jwt_token");
    _token = null;
    _username = null;
    _email = null;
    notifyListeners();
  }
}
