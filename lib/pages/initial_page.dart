import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NaverMapSdk.instance.initialize(
      clientId: '9185xrvnqq', // Get from Naver Cloud Platform
    );
  } catch (e) {
    debugPrint("Naver Map initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ App',
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
