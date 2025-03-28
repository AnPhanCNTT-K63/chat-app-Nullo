import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'routes/router.dart';
import 'utils/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background message received: ${message.notification?.title}");
}

void main() async {
  await _initializeApp();
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeFirebase();
    await dotenv.load(fileName: ".env");
    AppRouter.setupRouter();

    final token = await _getStoredToken();
    _runApp(token);
  } catch (e) {
    debugPrint("App initialization failed: $e");
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("✅ Firebase initialized successfully!");

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint("🔔 Notification permission: ${settings.authorizationStatus}");
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<String?> _getStoredToken() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: "jwt_token");
}

void _runApp(String? token) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(initialRoute: token != null ? '/' : '/login'),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupFirebaseMessaging();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupFirebaseMessaging() {
    final notificationService = NotificationService(
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _scaffoldMessengerKey
    );

    notificationService.setupForegroundNotifications();
    notificationService.setupNotificationClickHandling();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nullo Chat',
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      onGenerateRoute: AppRouter.router.generator,
      initialRoute: widget.initialRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}