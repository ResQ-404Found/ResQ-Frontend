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
import 'pages/fire_page.dart';
import 'pages/landslide_page.dart';
import 'pages/flood_page.dart';
import 'pages/typhoon_page.dart';
import 'pages/earthquake_page.dart';
import 'pages/coldwave_page.dart';
import 'pages/disaster_list_page.dart';
import 'pages/password_reset_new_page.dart';
import 'pages/password_reset_request_page.dart';
import 'pages/password_reset_verify_page.dart';

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
  '/fire': (context) => const FirePage(),
  '/landslide': (context) => const LandslidePage(),
  '/flood': (context) => const FloodPage(),
  '/typhoon': (context) => const TyphoonPage(),
  '/earthquake': (context) => const EarthquakePage(),
  '/coldwave': (context) => const ColdwavePage(),
  '/disasterlist': (context) => const DisasterListPage(),
  '/password_reset_request' : (context) => const PasswordResetRequestPage(),
  '/password_reset_verify': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PasswordResetVerifyPage(email: args['email']);
  },
  '/password_reset_new': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PasswordResetNewPage(
      email: args['email'],
      code: args['code'],
    );
  },




};
