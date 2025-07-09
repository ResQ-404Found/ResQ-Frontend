import 'package:flutter/material.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/community_page.dart';
import 'pages/user_page.dart';
import 'pages/allposts_page.dart';
import 'pages/writepost_page.dart';
import 'pages/hotposts_page.dart';
import 'pages/withdrawl_page.dart';
import 'pages/disaster_menu_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginPage(),
  '/signup': (context) => SignUpPage(),
  '/map': (context) => MapPage(),
  '/chatbot': (context) => ChatbotPage(),
  '/community': (context) => CommunityMainPage(),
  '/user': (context) => UserProfilePage(),
  '/allposts': (context) => AllPostsPage(),
  '/hotposts': (context) => HotPostsPage(),
  '/createpost': (context) => PostCreatePage(),
  '/withdrawl': (context) => WithdrawalConfirmationPage(),
  '/disastermenu': (context) => DisasterMenuPage(),
  // 필요한 화면 계속 추가
};
