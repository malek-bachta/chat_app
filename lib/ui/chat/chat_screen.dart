import 'dart:io';

import 'package:chat_app/core/sevices/auth_service.dart';
import 'package:chat_app/core/sevices/chat_service.dart';
import 'package:chat_app/ui/components/chat_bubble.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

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
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FocusNode _focusNode = FocusNode();

  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute}";
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        FocusScope.of(context).unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  // void _onEmojiSelected(Emoji emoji) {
  //   _messageController
  //     ..text += emoji.emoji
  //     ..selection = TextSelection.fromPosition(
  //       TextPosition(offset: _messageController.text.length),
  //     );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close keyboard when tapping outside
        setState(() {
          _showEmojiPicker = false; // Also close emoji picker
        });
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(widget.receiverUserName),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageComposer(),
            // if (_showEmojiPicker) _buildEmojiPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessagesStream(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.error != null) {
          return const Center(
            child: Text('An error occurred'),
          );
        }
        final messages = snapshot.data?.docs;
        return ListView(
          reverse: true,
          controller: _scrollController,
          children:
              messages?.map((doc) => _buildMessageItem(doc)).toList() ?? [],
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    String time = _formatTimestamp(data['timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ChatBubble(
        message: data['message'],
        isCurrentUser: isCurrentUser,
        time: time,
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 12.0)
          .copyWith(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomInputField(
              controller: _messageController,
              label: 'Message',
              enableBorder: false,
              backgroundColor: Theme.of(context).colorScheme.background,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              focusNode: _focusNode,
              suffixIcon: IconButton(
                onPressed: _toggleEmojiPicker,
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage();
                _messageController.clear();
              }
            },
            child: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildEmojiPicker() {
  //   return SizedBox(
  //     height: 250,
  //     child: EmojiPicker(
  //       onEmojiSelected: (category, emoji) {
  //         _onEmojiSelected(emoji);
  //       },
  //       config: Config(
  //         columns: 8,
  //         emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
  //         verticalSpacing: 0,
  //         horizontalSpacing: 0,
  //         initCategory: Category.RECENT,
  //         bgColor: Theme.of(context).colorScheme.background,
  //         indicatorColor: Theme.of(context).colorScheme.primary,
  //         iconColor: Theme.of(context).colorScheme.onSurface,
  //         iconColorSelected: Theme.of(context).colorScheme.primary,
  //         backspaceColor: Theme.of(context).colorScheme.onSurface,
  //         skinToneDialogBgColor: Theme.of(context).colorScheme.surface,
  //       ),
  //     ),
  //   );
  // }
}
