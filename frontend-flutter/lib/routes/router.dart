import 'package:app_chat_nullo/views/account_screen.dart';
import 'package:app_chat_nullo/views/chat_screen.dart';
import 'package:app_chat_nullo/views/home_screen.dart';
import 'package:app_chat_nullo/views/login_screen.dart';
import 'package:app_chat_nullo/views/profile_screen.dart';
import 'package:app_chat_nullo/views/register_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final FluroRouter router = FluroRouter();

  static Handler _homeHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => HomeScreen(),
  );

  static Handler _loginHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => LoginScreen(),
  );

  static Handler _registerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => RegisterScreen(),
  );

  static Handler _acccountHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => AccountScreen(),
  );

  static Handler _profileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => ProfileScreen(),
  );

  static Handler _chatHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) => ChatScreen(),
  );

  static void setupRouter() {
    router.define("/", handler: _homeHandler);
    router.define("/login", handler: _loginHandler);
    router.define("/register", handler: _registerHandler);
    router.define("/account", handler: _acccountHandler);
    router.define("/profile", handler: _profileHandler);
    router.define("/chat", handler: _chatHandler);
  }
}