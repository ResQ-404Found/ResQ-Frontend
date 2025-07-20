import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'routes.dart';
import 'pages/disaster_detail_page.dart';
import 'pages/map_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Naver Map
  final naverMap = FlutterNaverMap();
  await naverMap.init(
    clientId: 'p9nizolo1p',
    onAuthFailed: (e) => debugPrint('NaverMap Auth Failed: $e'),
  );

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
