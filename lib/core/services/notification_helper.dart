import 'package:dio/dio.dart';
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

  void handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chat-technical-test-b78c8",
      "private_key_id": "9304492c2a33c47b746b456f049a7b4a5bfe185b",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQC/4ApA1gYNnpH3\n1yt7boA3o4DrE0z8rlgTvbScWKIzCYelubDRwfhPfBQabVlzGM4Td3BK0942Palu\nztQOYWTrDAOrKLuPA/574CwZBlgN2iSA1cqxvBy7RzsO05yqw0abb/mW19Rbw6JK\nedsNoz4QIawLsbHcnPHYmMMPf997oWl5E/us8uAJXoheNrXNboq3Go4YDlxHlc0/\ny8mwYYDxdUn+IbavYuSjI7NfZssgVI+7joe+HenJk42r0Q2dpAYBxOCqw8GPM7rV\ncAsgP7uO1ylqJrjkUYgaUyVePczPmpzEIVs1DCcwgLyCV6J4w+By7bKnb+dClmiE\nahEG3bijAgMBAAECgf9/akdkxrs+UA6ehkRZswdx6yGw+SAmq5/RfChzqmgLfEiX\nxLemkyhRoBO5eOPtiotOYgIvroHhgxEAhFhNNF/Ptiq5flMOpZhYqoSeGZhfmnyj\nEVWIsWJi+uo87kkbHJHGppUXljtutHsQ+dp9M+oCzFlzaoyx84amTss5f7DoZx/D\nhUmeOaopU9w1F3Q7sYlTB6tf3yofwP+bJbECrjUsoMJuRTmwDmwHRX04FNeer0e4\nuQx48GETF0IXm7AFxvkLANLekd7j4Tkx/MOLLTknp2R2SPIWkRJsaaA1H/TNcQEE\nLbJ4Y2zbJkTnvqEuLhAVI1XHYHYm9lvjzXN2RdECgYEA9VY3JXpZQTzTmLCR2Sni\n4hA9KilqZXuXWeflwkK2myE9pbQlxERvqF4wCwLHMWIRWXWuURDYOjOqGMfdSmrJ\nP/T7JLJGd160RwitfDwiZGNfYYvh1HIgPyvfZg9eDxa6sK3WXUscwr5TWrA+T0Um\nPHcAKbw/Eb8iwtPQGqlAxv8CgYEAyDb5XwYoQNobd+hyK/YlmxJveGfNUSf5v5nw\nH0j3XoCnLTxi3WYCIQktm5N7XfUvyTzWBLBNcFFwfCToDAl+6/e941C+byTTnFh9\nWWKyxhsWlH5g4+JctuArZAV2FSw6kQt6Gw3yj7+eIn2/rClchXidGBpOlvnHNPij\n/X8okl0CgYEAyijP6kcGEza/GVut4ueb+DHvZLWZ4aPU1JW9ArUcaXobpVZrpG3M\nIE30gq44W1328+N/z3b05gi6ig7vLyoNSXFiHRv16tkT7lCdO/kFUfl8mBG+9eNQ\n5R0OybeyBvbwwTONp3SEb4iLgPgncASH/F0Gul1PDx2T1Dzbh4yePxsCgYAFPgtB\nhbPAHvXhKeDzbbqGWPE6Qd2KZnWPosQ6zXpMqym1cYNVMLqVitv62t28FBNwPXuN\nG+CrNDaxyXWZ+xWrsAz0ysRxvJEd4uNFV+Q+c68frD91OBQdZbk9ITd6TnIqIhbM\nZo0XXnkRhiFirKKTjBjw7J9qLJgetvP0S0QQsQKBgA+qoxO2dFBY4GN/zBnwWTgU\nH1prJHV0xVuuyVOE0iyq19hMddkteC6aAWbUMq8ZcU2cW8bNMUKwC8wWVQwiNWJJ\nEmhdJ5qKUIQ8iiBPTsKMTtGmfc8jh23ZlfZMPSam5sbvMZI088+aED+5lXEIcF5I\ny1dNyBXY4Z9Trxxn0ygN\n-----END PRIVATE KEY-----\n",
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
