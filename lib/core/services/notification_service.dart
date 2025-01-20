import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationInitialized = false;

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<void> init() async {
    await _requestPermission();
    await _setupMessageHandlers();
    await _setupFlutterLocalNotification();

    String? deviceToken = await _firebaseMessaging.getToken();
    if (deviceToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceToken', deviceToken);
      print("Firebase Messaging Token: $deviceToken");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getDeviceTokenFromFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data()?['deviceToken'] as String?;
      }
    } catch (e) {
      print('Error fetching device token from Firestore: $e');
    }
    return null;
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('Permission granted: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  Future<void> _setupFlutterLocalNotification() async {
    if (_isFlutterLocalNotificationInitialized) return;

    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotification.initialize(initializationSettings);
    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) {
      // _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message);
      _showLocalNotification(message);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;

    if (notification != null && android != null) {
      await _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    print('Notification clicked: ${message.notification?.title}');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.notification?.title}');
  }

  Future<String> getAccessToken(
      Map<String, dynamic> serviceAccountJson, List<String> scopes) async {
    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      print("Access Token: ${credentials.accessToken.data}");
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return "";
    }
  }

  Map<String, dynamic> getRemoteMessageBody({
    required String deviceToken,
    required String userName,
    required String body,
    required String receiverId,
  }) {
    return {
      "message": {
        "token": deviceToken,
        "notification": {"title": userName, "body": body},
        "data": {"receiverId": receiverId},
      }
    };
  }

  Future<void> sendRemoteNotification({
    required String receiverId,
    required String userName,
    required String body,
    required String serverKey,
  }) async {
    try {
      final deviceToken = await getDeviceTokenFromFirestore(receiverId);
      if (deviceToken == null) {
        print('No device token found for user: $receiverId');
        return;
      }

      const url =
          "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send";

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $serverKey';

      final response = await dio.post(
        url,
        data: getRemoteMessageBody(
          deviceToken: deviceToken,
          userName: userName,
          body: body,
          receiverId: receiverId,
        ),
      );

      print("Notification sent: ${response.statusCode}");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
