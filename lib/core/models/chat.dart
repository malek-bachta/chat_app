import 'package:chat_app/core/models/message.dart';

class Chat {
  final String id;
  final List<String> participants;
  final List<Conversation> messages;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
  });

  Chat.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        participants = List<String>.from(json['participants']),
        messages = (json['messages'] as List<dynamic>)
            .map((message) => Conversation.fromJson(message as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages.map((x) => x.toJson()).toList();
    return data;
  }
}
