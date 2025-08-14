import 'package:flutter/material.dart';

import 'map_page.dart';
import 'chatbot_page.dart';
import 'community_page.dart';
import 'disaster_menu_page.dart';
import 'user_page.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (i) {
        if (i == currentIndex) return;
        _go(context, i);
      },
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedIconTheme: const IconThemeData(size: 30),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.place), label: '지도'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '재난메뉴'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '마이'),
      ],
    );
  }

  static void _go(BuildContext context, int index) {
    final Widget page = switch (index) {
      0 => const MapPage(),
      1 => const ChatbotPage(),
      2 => const CommunityMainPage(),
      3 => const DisasterMenuPage(),
      4 => const UserProfilePage(),
      _ => const MapPage(),
    };

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    );
  }
}
