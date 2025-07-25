import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handle background messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 Handling a background message: ${message.messageId}');
}

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    // Request user permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle FCM token (skip safely on iOS simulator)
    if (!kIsWeb && Platform.isIOS) {
      bool isSimulator = Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
      if (!isSimulator) {
        try {
          String? token = await _firebaseMessaging.getToken();
          print('📲 FCM Token: $token');
        } catch (e) {
          print('❌ Error getting FCM token: $e');
        }
      } else {
        print('⚠️ Skipping FCM token on iOS simulator');
      }
    } else {
      try {
        String? token = await _firebaseMessaging.getToken();
        print('📲 FCM Token: $token');
      } catch (e) {
        print('❌ Error getting FCM token: $e');
      }
    }

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      // Handle in-app message UI here (e.g., dialogs/snackbars)
    });

    // When the app is opened from a terminated state via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification clicked: ${message.notification?.title}');
      // Navigate or handle logic on notification click
    });
  }
}
