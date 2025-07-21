import 'package:flutter/material.dart';
import 'pages/disaster_guide_page.dart';
import 'pages/disastertype_filtering_page.dart';
import 'pages/region_category_page.dart';
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
import 'pages/initial_page.dart';
import 'pages/checklist.dart';

final Map<String, WidgetBuilder> routes = {
  '/initial': (context) => const InitialPage(),
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
  '/fire': (context) => DisasterGuidePage(initialIndex: 0),
  '/landslide': (context) => DisasterGuidePage(initialIndex: 1),
  '/flood': (context) => DisasterGuidePage(initialIndex: 2),
  '/typhoon': (context) => DisasterGuidePage(initialIndex: 3),
  '/earthquake': (context) => DisasterGuidePage(initialIndex: 4),
  '/coldwave': (context) => DisasterGuidePage(initialIndex: 5),
  '/region-filter': (context) => RegionCategoryPage(),
  '/type-filter': (context) => NotificationSettingsPage(),
  '/disasterlist': (context) => DisasterGuidePage(initialIndex: 0),
  '/checklist' : (context) => const ChecklistPage(),
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
