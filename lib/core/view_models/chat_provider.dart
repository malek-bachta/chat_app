// import 'dart:convert';

import 'package:chat_app/core/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/models/message.dart';

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
  Stream<Chat?> getChatData(String uid1, String uid2) {
    String chatRoomId = _generateChatId(uid1, uid2);
    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return Chat.fromJson(data);
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

  /// Log error utility
  void logError(String functionName, String error) {
    print('$functionName: $error');
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

  Future<void> sendchatMessage(
    String uid1,
    String uid2,
    Message message,
  ) async {
    String chatRoomId = _generateChatId(uid1, uid2);
    final docRef = _fireStore.collection('chat_rooms').doc(chatRoomId);

    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }
}
