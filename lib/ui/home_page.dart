import 'package:chat_app/core/sevices/chat_service.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:chat_app/ui/chat/chat_screen.dart';
import 'package:chat_app/ui/components/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/sevices/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
          title: const Text(
            'Messenger',
          ),
        ),
        body: _buildUserList());
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData['uid'] != _authService.getCurrentUser()!.uid) {
      return UserTile(
        text: userData['userName'],
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverUserName: userData['userName'],
                receiverID: userData['uid'],
                receiverEmail: userData['email'],
              ),
            ),
          );
        },
      );
    } else {
      return Container(); // Placeholder for user tile
    }
  }
}
