import 'package:flutter/material.dart';
import 'map_page.dart';
import 'chatbot_page.dart';
import 'community_page.dart';
import 'disaster_menu_page.dart';
import 'user_page.dart';

class MainScaffoldPage extends StatefulWidget {
  const MainScaffoldPage({super.key});

  @override
  State<MainScaffoldPage> createState() => _MainScaffoldPageState();
}

class _MainScaffoldPageState extends State<MainScaffoldPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MapPage(),
    ChatbotPage(),
    CommunityMainPage(),
    DisasterMenuPage(),
    UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 30),
        items: const [
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)), label: '지도'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)), label: '채팅'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)), label: '재난메뉴'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)), label: '마이'),
        ],
      ),
    );
  }
}
