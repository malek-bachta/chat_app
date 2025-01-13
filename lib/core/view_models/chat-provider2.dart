import 'package:chat_app/core/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/models/message.dart';

class ChatProvider2 with ChangeNotifier {
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
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final currentUserID = user.uid;
      final currentUserEmail = user.email!;
      final timestamp = Timestamp.now();
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        // timestamp: timestamp.toDate(),
        timestamp: timestamp,
      );

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      final chatRoomID = ids.join('_');

      await _fireStore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .add(newMessage.toJson());
    } catch (e) {
      logError('sendMessage', e.toString());
    }
  }

  /// Send a message

  // / Get message stream between two users
  Stream<QuerySnapshot> getMessagesStream(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    final chatRoomID = ids.join('_');

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Update user status (online/offline)
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final currentStatus = isOnline;
        if (currentStatus != isOnline) {
          await _fireStore.collection('Users').doc(user.uid).update({
            'isOnline': isOnline,
            'lastSeen': isOnline ? null : Timestamp.now(),
          });
          notifyListeners();
        }
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

  /// Mark a message as read
  Future<void> markMessageAsRead(String chatRoomID, String messageID) async {
    try {
      await _fireStore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .doc(messageID)
          .update({'isRead': true});
    } catch (e) {
      logError('markMessageAsRead', e.toString());
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String chatRoomID, String messageID) async {
    try {
      await _fireStore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .doc(messageID)
          .delete();
    } catch (e) {
      logError('deleteMessage', e.toString());
    }
  }

  /// Update typing status
  Future<void> updateTypingStatus(String chatRoomID, bool isTyping) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _fireStore.collection('chat_rooms').doc(chatRoomID).update({
          '${user.uid}_isTyping': isTyping,
        });
      }
    } catch (e) {
      logError('updateTypingStatus', e.toString());
    }
  }

  /// Listen to typing status
  Stream<Map<String, dynamic>> getTypingStatus(String chatRoomID) {
    return _fireStore.collection('chat_rooms').doc(chatRoomID).snapshots().map(
          (doc) => doc.data() as Map<String, dynamic>,
        );
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
}
