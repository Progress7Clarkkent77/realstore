import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    await LocalNotificationService.show(
      title: message.notification!.title ?? 'New message',
      body: message.notification!.body ?? '',
    );
  }
}
