import 'package:chat_app/core/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _fireStore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  //send a message to a user
  Future<void> sendMessage(String receiverID, String message) async {
    final user = _auth.currentUser;
    final currentUserID = user!.uid;
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
  }

  //get messages between two users
  Stream<QuerySnapshot> getMessagesStream(String userID, otherUserID) {
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
