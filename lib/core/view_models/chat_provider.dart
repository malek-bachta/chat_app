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

  /// fech conversation between two users
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

  /// Fetch users and listen for changes in their online status
  void listenToUserStatus() {
    _fireStore.collection('Users').snapshots().listen((snapshot) {
      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
      notifyListeners();
    });
  }

  /// Update the current user's online status
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _fireStore.collection('Users').doc(user.uid).update({
          'isOnline': isOnline,
          'lastSeen': isOnline ? null : Timestamp.now(),
        });
      }
    } catch (e) {
      logError('updateUserStatus', e.toString());
    }
  }

  Future<bool> isUserOnline(String userId) async {
    final userDoc = await _fireStore.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return data?['isOnline'] ?? false;
    }
    return false;
  }

  /// Log error utility
  void logError(String functionName, String error) {
    print('$functionName: $error');
  }

  /// generate conversation id
  String _generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  /// Check if a chat room exists between two users
  Future<bool> checkChatRoomIfExists(String userId, String otherUserId) async {
    final chatId = _generateChatId(userId, otherUserId);
    final chatDoc = await _fireStore.collection('chat_rooms').doc(chatId).get();

    return chatDoc.exists;
  }

  /// Create a chat room between two users
  Future<void> createChatRoom(String userId, String otherUserId) async {
    final chatId = _generateChatId(userId, otherUserId);
    final chatDoc = _fireStore.collection('chat_rooms').doc(chatId);

    await chatDoc.set({
      'id': chatId,
      'participants': [userId, otherUserId],
      'messages': [],
    });
  }

  Future<void> handleChatRooms(String userId, String otherUserId) async {
    final chatExists = await checkChatRoomIfExists(userId, otherUserId);
    if (!chatExists) {
      await createChatRoom(userId, otherUserId);
    }
  }

  // Get the last message for a specific user
  Stream<List<Map<String, dynamic>>> getLastMessagesStream(
      String userId, String otherUserId) {
    final chatId = _generateChatId(userId, otherUserId);
    return _fireStore
        .collection('chat_rooms')
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return (data?['messages'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    });
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
