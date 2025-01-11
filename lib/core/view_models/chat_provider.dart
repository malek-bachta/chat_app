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

  /// Fetch users and update state
  Future<void> fetchUsers() async {
    try {
      _setLoading(true);
      final snapshot = await _fireStore.collection('Users').get();
      _users = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
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
        timestamp: timestamp.toDate(),
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
      print('Error sending message: $e');
    }
  }

  /// Get message stream between two users
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
}