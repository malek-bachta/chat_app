// import 'package:chat_app/core/services/notification_service.dart';
import 'package:chat_app/core/services/notification_helper.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/firebase_options.dart';

import 'core/view_models/auth_provider.dart';
import 'core/view_models/chat_provider.dart';
// import 'ui/notification_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await NotificationService.instance.init();

// Initialize Notifications
  final notificationsHelper = NotificationsHelper();
  await notificationsHelper.initNotifications();
  notificationsHelper.handleBackgroundNotifications();

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
        home: authProvider.user != null ? const HomePage() : const LoginView(),
        // home: const NotificationExample(),
      );
    });
  }
}


// import 'package:chat_app/core/services/notification_service.dart';
// import 'package:chat_app/themes/light_mode.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:chat_app/ui/home_page.dart';
// import 'package:chat_app/ui/authentication/login.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'core/view_models/auth_provider.dart';
// import 'core/view_models/chat_provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Determine the environment
//   const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

//   // Initialize Firebase with environment-specific options
//   FirebaseOptions firebaseOptions;
//   if (env == 'dev') {
//     firebaseOptions = FirebaseOptions(
//       apiKey: "DEV_API_KEY",
//       projectId: "DEV_PROJECT_ID",
//       messagingSenderId: "DEV_SENDER_ID",
//       appId: "DEV_APP_ID",
//     );
//   } else if (env == 'prod') {
//     firebaseOptions = FirebaseOptions(
//       apiKey: "PROD_API_KEY",
//       projectId: "PROD_PROJECT_ID",
//       messagingSenderId: "PROD_SENDER_ID",
//       appId: "PROD_APP_ID",
//     );
//   } else {
//     throw Exception('Unknown environment: $env');
//   }

//   await Firebase.initializeApp(options: firebaseOptions);

//   // Initialize Notification Service
//   await NotificationService.instance.init();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//       ],
//       child: MyApp(env: env),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final String env;

//   const MyApp({super.key, required this.env});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthenticationProvider>(
//       builder: (context, authProvider, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: lightMode,
//           home: authProvider.user != null ? HomePage() : LoginView(),
//           builder: (context, child) {
//             return Banner(
//               location: BannerLocation.topStart,
//               message: env.toUpperCase(),
//               color: env == 'prod' ? Colors.green : Colors.blue,
//               child: child!,
//             );
//           },
//         );
//       },
//     );
//   }
// }
