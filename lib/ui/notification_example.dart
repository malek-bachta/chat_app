import 'package:chat_app/core/services/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationExample extends StatefulWidget {
  const NotificationExample({super.key});

  @override
  _NotificationExampleState createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  final NotificationsHelper _notificationsHelper = NotificationsHelper();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationsHelper.initNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _notificationsHelper.handleMessages(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _notificationsHelper.handleMessages(message);
    });

    _notificationsHelper.handleBackgroundNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Example")),
      body: Center(
          child: Column(
        children: [
          Text("Check your notifications"),
          TextButton(
            onPressed: () async {
              await _notificationsHelper.sendNotifications(
                fcmToken:
                    "cVhhLubsRVCQxAsW4DMWUl:APA91bHIp8jjzs2nvorQSCFlGBcL8FpU1H9zURvPda0OxQlXD8vdn-_mIhoWd96eM0Y3g0Uv3W1_XmuysobK4X8dAjfdoTaBhJcp3OZK9883lJghHlI8164", // Replace with a real token
                title: "New Offer",
                body: "Check out the latest offers in your area!",
                userId: "12345",
              );
            },
            child: Text("Send Notification"),
          )
        ],
      )),
    );
  }
}
