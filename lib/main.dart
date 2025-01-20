import 'package:chat_app/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/firebase_options.dart';

import 'core/services/notification_service.dart';
import 'core/view_models/auth_provider.dart';
import 'core/view_models/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: (authProvider.user != null && authProvider.isRememberMe)
            ? const HomePage()
            : const LoginView(),
      );
    });
  }
}
