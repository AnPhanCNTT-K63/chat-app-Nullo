import 'package:app_chat_nullo/providers/socket_provider.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:app_chat_nullo/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print("API_URL: ${dotenv.env['API_URL']}");

  AppRouter.setupRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SocketProvider()),
      ],
      child: MyApp(),
    ),
  );
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
