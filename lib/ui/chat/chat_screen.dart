import 'package:chat_app/core/models/chat.dart';
import 'package:chat_app/core/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view_models/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverID;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.receiverUserName,
    required this.receiverID,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final User chatUser = FirebaseAuth.instance.currentUser!;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(
      id: chatUser.uid,
      firstName: chatUser.displayName,
    );
    otherUser = ChatUser(
      id: widget.receiverID,
      firstName: widget.receiverUserName,
    );
  }

  Future<void> _sendMessage(
      ChatMessage chatmessage, ChatProvider chatprovider) async {
    Message message = Message(
      senderID: chatUser.uid,
      senderEmail: chatUser.email!,
      receiverID: widget.receiverID,
      message: chatmessage.text,
      timestamp: Timestamp.fromDate(chatmessage.createdAt),
    );
    await chatprovider.sendchatMessage(
      chatUser.uid,
      widget.receiverID,
      message,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(widget.receiverUserName),
          centerTitle: true,
        ),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return _buildUi(chatProvider);
          },
        ),
      ),
    );
  }

  Widget _buildUi(ChatProvider chatProvider) {
    return StreamBuilder<Chat?>(
      stream: chatProvider.getChatData(chatUser.uid, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred while loading the chat.'),
          );
        }
        final chat = snapshot.data;
        final messages = _generateChatMessagesList(chat!.messages);
        return DashChat(
          messageListOptions: const MessageListOptions(
            showFooterBeforeQuickReplies: true,
            showDateSeparator: true,
          ),
          inputOptions: const InputOptions(
            alwaysShowSend: true,
          ),
          currentUser: currentUser!,
          onSend: (message) {
            _sendMessage(message, chatProvider);
          },
          messages: messages,
        );
      },
    );
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    return messages.map((msg) {
      return ChatMessage(
        text: msg.message,
        user: msg.senderID == chatUser.uid ? currentUser! : otherUser!,
        createdAt: msg.timestamp.toDate(),
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
