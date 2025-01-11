
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/view_models/auth_provider.dart';
import '../core/view_models/chat_provider.dart';
import 'chat/chat_screen.dart';
import 'components/user_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await Provider.of<AuthenticationProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chatProvider.users.length,
              itemBuilder: (context, index) {
                final user = chatProvider.users[index];
                if (user['uid'] != FirebaseAuth.instance.currentUser?.uid) {
                  return UserTile(
                    text: user['userName'],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverUserName: user['userName'],
                            receiverID: user['uid'],
                            receiverEmail: user['email'],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Container(); // Skip current user
              },
            ),
    );
  }
}