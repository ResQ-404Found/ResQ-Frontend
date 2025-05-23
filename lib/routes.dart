import 'package:flutter/material.dart';
import 'login_page.dart';
import 'password_reset.dart';
import 'passwordresetemailsentpage.dart';
import 'passwordresetnewpage.dart';
import 'signup_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/initial': (context) => const LoginPage(),
  '/main': (context) => const MainPage(),
  '/mypage': (context) => const MyPage(),
  '/password-reset': (context) => const PasswordResetEmailPage(),
  
  
  
  /* uni_link 이랑 연결해서 매일 확인 할 때 이렇게 써야하는데 지금 못 써
  '/email-sent': (context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    return PasswordResetEmailSentPage(email: email);
  },
  '/new-password': (context) {
    final token = ModalRoute.of(context)!.settings.arguments as String;
    return PasswordResetNewPage(token: token);
  },
  */
};
