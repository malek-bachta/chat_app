import 'package:chat_app/ui/authentication/login.dart';
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
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();

    _chatProvider?.updateUserStatus(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _chatProvider?.fetchUsers();
    });
  }

  @override
  void dispose() {
    _chatProvider?.updateUserStatus(false);
    super.dispose();
  }

  void _logout(BuildContext context) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await chatProvider.updateUserStatus(false);
      await authProvider.logout();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginView(),
          ),
        );
      }
    }
  }

  Future<void> _refreshUsers() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.fetchUsers();
  }

  void _onUserTap(String currentUserId, Map<String, dynamic> user) async {
    await _chatProvider?.ensureChatExists(currentUserId, user['uid']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverUserName: user['email'],
          receiverID: user['uid'],
          receiverEmail: user['email'],
          receiverToken: user['deviceToken'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshUsers,
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.users.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatProvider.users.length,
                        itemBuilder: (context, index) {
                          final user = chatProvider.users[index];
                          if (user['uid'] == currentUserId) {
                            return const SizedBox.shrink();
                          }

                          return FutureBuilder<String>(
                            future: chatProvider.getLastMessage(
                              currentUserId ?? '',
                              user['uid'],
                            ),
                            builder: (context, snapshot) {
                              final lastMessage = snapshot.data ?? 'Loading...';

                              return UserTile(
                                text: user['userName'],
                                lastMessage: lastMessage,
                                onTap: () =>
                                    _onUserTap(currentUserId ?? '', user),
                                trailing: Icon(
                                  Icons.circle,
                                  color: user['isOnline'] ?? false
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12,
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
