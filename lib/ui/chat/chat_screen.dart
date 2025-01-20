import 'package:chat_app/core/models/chat.dart';
import 'package:chat_app/core/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_helper.dart';
import '../../core/view_models/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverID;
  final String receiverEmail;
  final String receiverToken;

  const ChatScreen({
    super.key,
    required this.receiverUserName,
    required this.receiverID,
    required this.receiverEmail,
    required this.receiverToken,
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

  final NotificationsHelper _notificationsHelper = NotificationsHelper();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();

    currentUser = ChatUser(
      id: chatUser.uid,
      firstName: chatUser.displayName,
    );
    otherUser = ChatUser(
      id: widget.receiverID,
      firstName: widget.receiverUserName,
    );
  }

  String _sanitizeText(String input) {
    return input.split('@').first.replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
  }

  Future<void> _initializeNotifications() async {
    // Initialize notifications
    await _notificationsHelper.initNotifications();

    // Handle notifications in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });

    // Handle notifications when app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });

    // Handle background notifications
    _notificationsHelper.handleBackgroundNotifications();
  }

  void _handleIncomingNotification(RemoteMessage message) {
    _notificationsHelper.handleMessages(message);

    if (message.data['type'] == 'chat' &&
        message.data['senderID'] == widget.receiverID) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _isMessageValid(String message) {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      return false;
    } else if (trimmedMessage.length > 500) {
      return false;
    }

    return true;
  }

  Future<void> _sendMessage(
    ChatMessage chatMessage,
    ChatProvider chatProvider,
  ) async {
    final trimmedMessageText = chatMessage.text.trim();

    if (trimmedMessageText.isEmpty) return;
    final message = Message(
      senderID: chatUser.uid,
      senderEmail: chatUser.email!,
      receiverID: widget.receiverID,
      message: trimmedMessageText,
      timestamp: Timestamp.fromDate(chatMessage.createdAt),
    );
    await chatProvider.sendchatMessage(
        chatUser.uid, widget.receiverID, message);
    String email = widget.receiverEmail;
    if (email.endsWith('@gmail.com')) {
      await _notificationsHelper.sendNotification(
        deviceToken: widget.receiverToken,
        receiverId: widget.receiverID,
        userName: _sanitizeText(chatUser.email!),
        message: message.message,
      );
    }

    _scrollToBottom();
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(_sanitizeText(widget.receiverUserName)),
          centerTitle: true,
        ),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return _buildChatUi(chatProvider);
          },
        ),
      ),
    );
  }

  Widget _buildChatUi(ChatProvider chatProvider) {
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
        final messages = _generateChatMessagesList(chat?.messages ?? []);

        return DashChat(
          messageListOptions: const MessageListOptions(
            showFooterBeforeQuickReplies: true,
            showDateSeparator: true,
          ),
          inputOptions: const InputOptions(
            alwaysShowSend: true,
          ),
          messageOptions: MessageOptions(
            showTime: true,
            currentUserContainerColor: Colors.amber[700]!,
            containerColor: Theme.of(context).colorScheme.secondary,
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
