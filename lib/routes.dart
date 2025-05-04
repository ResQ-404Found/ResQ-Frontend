import 'package:flutter/material.dart';
import 'pages/initial_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/initial': (context) => InitialPage(),
  '/signup': (context) => SignUpPage(),
  '/home': (context) => LoginPage(),
  // 필요한 화면 계속 추가
};