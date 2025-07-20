import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inter/pages/firebase_options.dart';

import 'routes.dart';
import 'pages/disaster_detail_page.dart';
import 'pages/map_page.dart';

/// ✅ Handles background FCM messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Naver Map
  final naverMap = FlutterNaverMap();
  await naverMap.init(
    clientId: 'p9nizolo1p',
    onAuthFailed: (e) => debugPrint('NaverMap Auth Failed: $e'),
  );

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // ✅ Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'No Title';
        final body = message.notification!.body ?? 'No Body';


        // Show snackbar as notification UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🔔 $title\n$body')),
          );
        });
      }
    });

    // ✅ Notification tapped listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // You can navigate to a specific page here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      initialRoute: '/login',
      routes: routes,
      onGenerateRoute: (settings) {
        if (settings.name == '/disasterDetail') {
          final disaster = settings.arguments as Disaster;
          return MaterialPageRoute(
            builder: (context) => DisasterDetailPage(disaster: disaster),
          );
        }
        return null;
      },
    );
  }
}
