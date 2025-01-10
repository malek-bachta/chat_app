import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/sevices/auth_service.dart';
import 'package:chat_app/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final AuthService authService = AuthService();
  final bool isLoggedIn = await authService.isUserLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: isLoggedIn ? const HomePage() : const LoginView(),
    );
  }
}
