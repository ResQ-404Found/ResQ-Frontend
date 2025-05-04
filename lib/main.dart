import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(MyApp());
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