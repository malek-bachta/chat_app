import 'dart:convert';

import 'package:chat_app/core/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Get the current user's ID
  String? getCurrentUserID() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // Fetch users and update state
  Future<void> fetchUsers() async {
    try {
      _setLoading(true);
      final snapshot = await _fireStore.collection('Users').get();
      _users = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    } catch (e) {
      logError('fetchUsers', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message

  // Future<void> sendchatMessage(String uid1, uid2, Message message) async {
  //   String chatRoomId = _generateChatId(uid1, uid2);
  //   final docRef = _fireStore.collection('chat_rooms').doc(chatRoomId);
  //   await docRef.update({
  //     'messages': FieldValue.arrayUnion([message.toJson()])
  //   });
  // }

  Stream<Chat?> getChatData(String uid1, String uid2) {
    String chatRoomId = _generateChatId(uid1, uid2);
    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null; // Handle case where chat room doesn't exist
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return Chat.fromJson(data); // Map Firestore data to Chat model
    });
  }

  /// Update user status (online/offline)
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _fireStore.collection('Users').doc(user.uid).update({
          'isOnline': isOnline,
          'lastSeen': isOnline ? null : Timestamp.now(),
        });
        notifyListeners();
      }
    } catch (e) {
      logError('updateUserStatus', e.toString());
    }
  }

  /// Check if a chat exists
  String _generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Future<bool> checkIfChatExists(String uid1, String uid2) async {
    final chatId = _generateChatId(uid1, uid2);
    final chat = await _fireStore.collection('chat_rooms').doc(chatId).get();
    if (chat.exists) {
      return true;
    }
    return false;
  }

  /// Create a chat
  Future<void> createChat(String uid1, String uid2) async {
    final chatId = _generateChatId(uid1, uid2);
    final docRef = _fireStore.collection('chat_rooms').doc(chatId);
    final chat = Chat(
      id: chatId,
      participants: [uid1, uid2],
      messages: [],
    );

    await docRef.set(chat.toJson());
  }

  /// Delete a message
  Future<void> deleteMessage(String chatRoomID, String messageID) async {
    try {
      await _fireStore.collection('chat_rooms').doc(chatRoomID).update({
        'messages': FieldValue.arrayRemove([
          {'id': messageID}
        ])
      });
    } catch (e) {
      logError('deleteMessage', e.toString());
    }
  }

  /// Fetch a single user's data
  Future<Map<String, dynamic>?> getUserData(String userID) async {
    try {
      final doc = await _fireStore.collection('Users').doc(userID).get();
      return doc.data();
    } catch (e) {
      logError('getUserData', e.toString());
      return null;
    }
  }

  /// Log error utility
  void logError(String functionName, String error) {
    print('$functionName: $error');
    // Optionally, send logs to an external monitoring service
  }

  // Ensure chat exists between two users
  Future<void> ensureChatExists(String userId, String otherUserId) async {
    final chatId = _generateChatId(userId, otherUserId);
    final chatDoc = _fireStore.collection('chat_rooms').doc(chatId);

    final existingChat = await chatDoc.get();
    if (!existingChat.exists) {
      await chatDoc.set({
        'id': chatId,
        'participants': [userId, otherUserId],
        'messages': [],
      });
    }
  }

  // Get the last message for a specific user
  Future<String> getLastMessage(String userId, String otherUserId) async {
    final chatId = _generateChatId(userId, otherUserId);
    final chatDoc = await _fireStore.collection('chat_rooms').doc(chatId).get();

    if (chatDoc.exists) {
      final data = chatDoc.data() as Map<String, dynamic>;
      final messages = data['messages'] as List<dynamic>;
      if (messages.isNotEmpty) {
        final lastMessage = messages.last as Map<String, dynamic>;
        return lastMessage['message'] ?? 'No messages yet';
      }
    }
    return 'No messages yet';
  }

  Future<String?> _getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceToken');
  }

  Future<void> sendchatMessage(
      String uid1, String uid2, Message message) async {
    String chatRoomId = _generateChatId(uid1, uid2);
    final docRef = _fireStore.collection('chat_rooms').doc(chatRoomId);

    // Update chat room messages
    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });

    String? fcmToken = await _getLocalToken();

    if (fcmToken != null) {
      await _sendPushNotification(fcmToken, message.message);
      print(
          'Simulating push notification to: $fcmToken with message: ${message.message}');
    }
  }
}

Future<void> _sendPushNotification(String fcmToken, String messageText) async {
  const serverKey = 'chat-technical-test-b78c8';
  final url = Uri.parse('https://fcm.googleapis.com/v1/projects');

  // final body = {
  //   'token': fcmToken,
  //   'notification': {
  //     'title': 'New Message',
  //     'body': messageText,
  //     'sound': 'default',
  //   },
  //   'data': {
  //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //     'message': messageText,
  //   },
  final body = {
    "message": {
      "token": fcmToken,
      "notification": {
        "title": "You got a new message",
        "body": messageText,
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
      "data": {
        "type": "type",
        "id": "userId",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    }
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  await http.post(url, headers: headers, body: jsonEncode(body));
}
