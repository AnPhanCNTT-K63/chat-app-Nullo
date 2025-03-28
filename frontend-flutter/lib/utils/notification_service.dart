import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  NotificationService({
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  void setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void setupNotificationClickHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);
  }


  void _handleForegroundMessage(RemoteMessage message) {
    String? currentPath;
    navigatorKey.currentState?.popUntil((route) {
      currentPath = route.settings.name;
      return true;
    });
    if (message.notification == null || currentPath == "/chat") return;

    final avatarPath = _tryParseAvatarPath(message);

    if (avatarPath.isNotEmpty) {
      _loadImageAndShowNotification(message, avatarPath);
    } else {
      _showDefaultNotification(message);
    }
  }

  String _tryParseAvatarPath(RemoteMessage message) {
    try {
      return jsonDecode(message.data['senderImage']) as String;
    } catch (e) {
      debugPrint('Error parsing avatar path: $e');
      return '';
    }
  }

  void _loadImageAndShowNotification(RemoteMessage message, String avatarPath) {
    final completer = Completer<void>();
    final imageProvider = NetworkImage(avatarPath);

    imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool syncCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception);
          }
        },
      ),
    );

    completer.future.then((_) {
      _showNotificationWithAvatar(message, avatarPath);
    }).catchError((_) {
      _showDefaultNotification(message);
    });
  }

  void _showNotificationWithAvatar(RemoteMessage message, String avatarPath) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _buildNotificationSnackBar(
        message,
        avatarWidget: ClipOval(
          child: Image.network(
            avatarPath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultAvatarWidget(),
          ),
        ),
      ),
    );
  }

  void _showDefaultNotification(RemoteMessage message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _buildNotificationSnackBar(
        message,
        avatarWidget: _defaultAvatarWidget(),
      ),
    );
  }

  Widget _defaultAvatarWidget() {
    return CircleAvatar(
      backgroundImage: AssetImage('assets/default_avatar.png'),
      radius: 25,
    );
  }

  SnackBar _buildNotificationSnackBar(
      RemoteMessage message, {
        required Widget avatarWidget,
      }) {
    return SnackBar(
      content: Row(
        children: [
          avatarWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.notification!.title ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (message.notification!.body != null)
                  Text(
                    message.notification!.body!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 6,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'View',
        textColor: Colors.white,
        onPressed: () => _handleNotificationNavigation(message),
      ),
    );
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    try {
      debugPrint("🚀 Navigating to chat screen... ${message.data}");
      final sender = jsonDecode(message.data['sender']) as Map<String, dynamic>;
      final conversationId = jsonDecode(message.data['conversationId']) as String;

      navigatorKey.currentState?.pushNamed('/chat', arguments: {
        'user': sender,
        'conversationId': conversationId,
      });
    } catch (e) {
      debugPrint('Error parsing receiver data: $e');
    }
  }
}