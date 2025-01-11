class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> data) {
    return Message(
      senderID: data['senderID'],
      senderEmail: data['senderEmail'],
      receiverID: data['receiverID'],
      message: data['message'],
      timestamp: data['timestamp'].toDate(),
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
