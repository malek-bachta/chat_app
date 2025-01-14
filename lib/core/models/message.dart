import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  // final DateTime timestamp;
  final Timestamp timestamp;

  Conversation({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> data) {
    return Conversation(
      senderID: data['senderID'],
      senderEmail: data['senderEmail'],
      receiverID: data['receiverID'],
      message: data['message'],
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
