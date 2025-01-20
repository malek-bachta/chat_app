import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'themes/light_mode.dart';
import 'ui/home_page.dart';
import 'ui/authentication/login.dart';
import 'core/services/notification_service.dart';
import 'core/view_models/auth_provider.dart';
import 'core/view_models/chat_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

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
          home: _determineStartPage(authProvider),
        );
      },
    );
  }

  Widget _determineStartPage(AuthenticationProvider authProvider) {
    if (authProvider.user != null && authProvider.isRememberMe) {
      return const HomePage();
    } else {
      return const LoginView();
    }
  }
}
