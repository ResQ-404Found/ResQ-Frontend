import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'initial_page.dart';

void main() {
  runApp(MyApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NaverMapSdk.instance.initialize(
      clientId: '9185xrvnqq', // Get from Naver Cloud Platform
    );
  } catch (e) {
    debugPrint("Naver Map initialization failed: $e");
  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //시작 화면 경로
      initialRoute: '/initial',
      //루트 연결
      routes: appRoutes,
    );
  }
}