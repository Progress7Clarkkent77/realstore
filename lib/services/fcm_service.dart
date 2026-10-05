import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 🔐 Request permission (Android 13+)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 🔑 Get token (store this in Firestore later)
    final token = await _messaging.getToken();
    print('📱 FCM Token: $token');

    // 🔔 Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotificationService.show(
          title: message.notification!.title ?? 'New message',
          body: message.notification!.body ?? '',
        );
      }
    });

    // 🔔 When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification clicked');
    });
  }
}
