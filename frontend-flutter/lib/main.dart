import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:app_chat_nullo/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

/// ✅ Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("✅ Firebase initialized successfully!");

    /// ✅ Request notification permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    print("🔔 Notification permission: ${settings.authorizationStatus}");

    /// ✅ Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  await dotenv.load(fileName: ".env");

  AppRouter.setupRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();  // ✅ Call global notification setup
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("📩 Foreground Notification: ${message.notification!.title}");

        // Show a local notification if needed (Example: Snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.notification!.title ?? "New message")),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 User clicked the notification!");
      if (message.data.containsKey('conversationId')) {
        Navigator.pushNamed(context, '/chat', arguments: {
          'conversationId': message.data['conversationId'],
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nullo Chat',
      onGenerateRoute: AppRouter.router.generator,
      initialRoute: '/',
    );
  }
}
