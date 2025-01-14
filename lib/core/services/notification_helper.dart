// import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsHelper {
  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;
  NotificationsHelper._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    _requestPermission();
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

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('Permission granted: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      print(
          'Notification received: ${message.notification?.title} - ${message.notification?.body}');
    }
  }

  // void handleMessages(RemoteMessage? message) {
  //   if (message != null) {
  //     // navigatorKey.currentState?.pushNamed(NotificationsScreen.routeName, arguments: message);
  //     Fluttertoast.showToast(
  //       msg: 'on Background Message notification',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       fontSize: 16.0,
  //     );
  //   }
  // }

  void handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }
  

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chat-technical-test-b78c8",
      "private_key_id": "7f270b4a5e3830a2d227d62d511532f5449cecc6",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCnMF6oAWM2Ao2u\nYM4H8ohtIoF36AKrg0nXUG8ONbUPPNoNNc+D5caEF3TmDQI51GgTQ6AltWhCiMO+\nWYXSD4JsznWaPdhJ7JWLH63sPMENBH4ovUpaW0xuIG6Q2gkdvqc0jlY5pgHuFxpO\nZrPFyYi9X+irzPAyksZFnZ0cKSasPdEsUh67VMm3U6DCdN06Q4jNRb3tF4pdHFdX\nUKNRQ2G88Vwtp6T1NCdEB3R6gXLDH1WT9FOSsi5uuDB71GmYXLa+xasz9uo6ZWTA\nt245VWj/22Mvgq35ziFJH8ufFvJ0VivtRCK3DHqpHuBZ7oQjZvUZ04KsydC89tr/\n2cpVtDcxAgMBAAECggEAQGI6MYzHPgdhtGOHNDxMGWsOXLS2QoJ+rzJEcj5wiXuv\npSKx1WNpPXkjBWzBDLAlnDWQuLTRf73XU7h59lkOqwQe+dUTM/St6jO68Jy841x1\nkQ7EUWOTXV2T9qhgllnTXkPqJK0vVRcEhGi8llB0HimPGooDfhZT0H9P/4ZBZFaS\nBzzXF1c3bkXgIyVBQ1rNY1AuSrfzZU2cvcaIbXVjFityOX/wFvWtT7JpCh5rKs1Q\noXZ07CJM0DXliX1TcsaX2tKvjAjm1Jg5PP/9NLT0GKU61m+cIxxx2uElShO3MXx9\nnxAoHCVqF6TSowNPDlQufZp8u65jGgrQ3VWtZsV3GQKBgQDha+ETQ6NzKT9ydXf3\nT6XH/7DWz5qIv+wpDqP1qTJg+xI464bT0vf4oCQ1TputF1onywkmhIaEC0b9nukf\nRF8U13w9jVYEGip/RA8l/e+xRxFcRCWTrj/8os5HJVRuwVcycg/HmSI5Y7XpXZAW\noSfs5BVPvI524yK/RHEJXU6JtwKBgQC93kZWbPpnUS9Hq1P3F+Ak/6yfRS/vcc39\n7RthuQxkbmLBQ10x32maC5OiNOPfV35iKFt67j82ZzqHM6L/q9+AApEzE0z70VLg\nkKsEz8tOYE3/lDTtzHju/22xuSVmab5J7Fi9GW+9ehXytPrb7xKdpSs3mkkJY4lh\n8YI/Nf/mVwKBgEVhWb3/JHCOcnu9EfZpakH7Padv8EVEpOAiJG6468uTmxEv1Kif\nlzjLuTk6/4kv1czHngJf6bL8cZYf8epwtb8Jb7DWLnJGx2uyO+NanAp5MCuwwcwJ\nZqJQTaLyJ2GLWlYpaxfo1vLI8LVp2a5NXad4r+KBy2tmD0zFOPFD6adTAoGAUP6h\n+LpSc4KBbcxbbDvmJUJgLC1Cjp14p0rfdGeRLsKcJB+NgPnyPYGUwAxZ7OuRAWR/\n6cf6dUXCBOz1KqXyGNR/hk9EduPLu/payhmue8e/Xjil/49LQ4D5FWiK2M5hG33U\nOQ7ByQ1skXW80deBlHhiID0TzQqGD58L1dU+Tc8CgYBxj4X40utivyiflS0qDL3z\njY/LHYzvsTAOhh3/hx+gevXpHG81rt6vHVDw6Z45nEk43NfAbrKQ9fjvgjryMZmh\nFwI2L2ZIXAd3wVix274YCuW+0tAFH4d7KBH7rblOkUzN4bE6v2wcFtz9awQ1CFJ+\nNQCm+OIUtN7ElH8RWlMeZw==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-8ei74@chat-technical-test-b78c8.iam.gserviceaccount.com",
      "client_id": "113861279161466980287",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-8ei74%40chat-technical-test-b78c8.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
      print(
          "===================Device FirebaseMessaging Token===================="
          "===================Device FirebaseMessaging Token====================");

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
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
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

      const String urlEndPoint =
          "https://fcm.googleapis.com/v1/projects/chat-technical-test-b78c8/messages:send";

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
