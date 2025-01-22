import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationsHelper {
  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;
  NotificationsHelper._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _requestPermission();
    String? deviceToken = await _firebaseMessaging.getToken();
    if (deviceToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceToken', deviceToken);
    }
    print(
        "===================Device FirebaseMessaging Token====================");
    print(deviceToken);
    print(
        "===================Device FirebaseMessaging Token====================");
  }

  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      print(
          'Notification received: ${message.notification?.title} - ${message.notification?.body}');
    }
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

  void handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": dotenv.env['SERVICE_ACCOUNT_TYPE']!,
      "project_id": dotenv.env['SERVICE_ACCOUNT_PROJECT_ID']!,
      "private_key_id": dotenv.env['SERVICE_ACCOUNT_PRIVATE_KEY_ID']!,
      "private_key": dotenv.env['SERVICE_ACCOUNT_PRIVATE_KEY']!,
      "client_email": dotenv.env['SERVICE_ACCOUNT_CLIENT_EMAIL']!,
      "client_id": dotenv.env['SERVICE_ACCOUNT_CLIENT_ID']!,
      "auth_uri": dotenv.env['SERVICE_ACCOUNT_AUTH_URI']!,
      "token_uri": dotenv.env['SERVICE_ACCOUNT_TOKEN_URI']!,
      "auth_provider_x509_cert_url":
          dotenv.env['SERVICE_ACCOUNT_AUTH_PROVIDER_X509_CERT_URL']!,
      "client_x509_cert_url":
          dotenv.env['SERVICE_ACCOUNT_CLIENT_X509_CERT_URL']!,
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

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

  Map<String, dynamic> getBody({
    required String deviceToken,
    required String userName,
    required String message,
    required String receiverId,
  }) {
    return {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": userName,
          "body": message,
        },
        "android": {
          "notification": {
            "channel_id": "high_importance_channel",
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "alert": {"title": userName, "body": message},
              "content_available": true
            }
          }
        },
        "data": {"id": receiverId, "click_action": "FLUTTER_NOTIFICATION_CLICK"}
      }
    };
  }

  Future<void> sendNotification({
    required String? deviceToken,
    required String userName,
    required String message,
    required String receiverId,
  }) async {
    try {
      var serverKeyAuthorization = await getAccessToken();

      final String urlEndPoint = dotenv.env['SERVICE_ACCOUNT_FCM_API_URL']!;

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

      var response = await dio.post(
        urlEndPoint,
        data: getBody(
          receiverId: receiverId,
          deviceToken: deviceToken!,
          userName: userName,
          message: message,
        ),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
