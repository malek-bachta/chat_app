import 'package:chat_app/core/view_models/chat-provider2.dart';
import 'package:chat_app/ui/components/chat_bubble.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool _showEmojiPicker = false;

  final User chatUser = FirebaseAuth.instance.currentUser!;

  ChatUser? currentUser, otherUser;

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _sendMessage(ChatProvider2 chatProvider) async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await chatProvider.sendMessage(widget.receiverID, message);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showEmojiPicker = false;
        });
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(widget.receiverUserName),
        ),
        body: Consumer<ChatProvider2>(
          builder: (context, chatProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: _buildMessageList(chatProvider),
                ),
                _buildMessageComposer(chatProvider),
                // if (_showEmojiPicker) _buildEmojiPicker(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatProvider2 chatProvider) {
    String senderID = chatProvider.getCurrentUserID()!;
    return StreamBuilder(
      stream: chatProvider.getMessagesStream(widget.receiverID, senderID),
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
    final chatProvider = Provider.of<ChatProvider2>(context, listen: false);
    bool isCurrentUser = data['senderID'] == chatProvider.getCurrentUserID();
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

  Widget _buildMessageComposer(ChatProvider2 chatProvider) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
                _sendMessage(chatProvider);
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
