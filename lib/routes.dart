import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_page.dart';
import 'mypage.dart';
import 'password_reset.dart';
import 'passwordresetemailsentpage.dart';
import 'passwordresetnewpage.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/initial': (context) => const LoginPage(),
  '/main': (context) => const MainPage(),
  '/mypage': (context) => const MyPage(),
  '/password-reset': (context) => const PasswordResetEmailPage(),
  '/email-sent': (context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    return PasswordResetEmailSentPage(email: email);
  },
  '/new-password': (context) {
    final token = ModalRoute.of(context)!.settings.arguments as String;
    return PasswordResetPage(token: token);
  },
};