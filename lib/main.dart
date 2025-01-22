import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/services/notification_helper.dart';
import 'firebase_options.dart';
import 'themes/light_mode.dart';
import 'ui/home_page.dart';
import 'ui/authentication/login.dart';
import 'core/view_models/auth_provider.dart';
import 'core/view_models/chat_provider.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationsHelper().handleMessages(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  // await dotenv.load(fileName: env == 'prod' ? '.env.prod' : '.env.dev');

  // await Firebase.initializeApp(
  //   options: FirebaseOptions(
  //     apiKey: dotenv.env['FIREBASE_API_KEY']!,
  //     projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
  //     appId: dotenv.env['FIREBASE_APP_ID']!,
  //     messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
  //     authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
  //   ),
  // );

  await dotenv.load(fileName: ".env");

  if (!dotenv.isInitialized ||
      dotenv.env['SERVICE_ACCOUNT_FCM_API_URL'] == null) {
    print("Error: Missing required environment variables.");
    return;
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationsHelper().initNotifications();

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
