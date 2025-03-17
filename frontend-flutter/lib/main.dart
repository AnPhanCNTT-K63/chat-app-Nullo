import 'package:app_chat_nullo/routes/router.dart';
import 'package:flutter/material.dart';

void main() {
  AppRouter.setupRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nullo Chat',
      onGenerateRoute: AppRouter.router.generator,
      initialRoute: '/',
    );
  }
}


