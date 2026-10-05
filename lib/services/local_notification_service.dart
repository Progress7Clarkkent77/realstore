import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// 🔔 Initialize notifications (call once in main)
  static Future<void> init() async {
    if (_initialized) return;

    // const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings: initSettings);

    _initialized = true;
  }

  /// 🔔 Show notification
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Incoming chat messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@drawable/ic_notification', // 🔥 YOUR LOGO
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
