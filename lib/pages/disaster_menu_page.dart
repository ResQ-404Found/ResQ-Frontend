import 'package:flutter/material.dart';

class DisasterMenuPage extends StatelessWidget {
  const DisasterMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': '전체 재난 정보', 'icon': Icons.warning_amber_rounded},
      {'title': '대처 방법', 'icon': Icons.security},
      {'title': '체크리스트', 'icon': Icons.check_box},
      {'title': '후원', 'icon': Icons.volunteer_activism},
      {'title': '뉴스', 'icon': Icons.article},
      {'title': 'QUIZ', 'icon': Icons.quiz},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('재난 대응 메뉴'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ListView.separated(
          itemCount: menuItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                if (item['title'] == '대처 방법') {
                  Navigator.pushNamed(context, '/disasterlist');
                }
                if (item['title'] == '체크리스트') {
                  Navigator.pushNamed(context, '/checklist');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, size: 28, color: Colors.teal),
                    const SizedBox(width: 16),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // 하단 바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색
              blurRadius: 10, // 퍼짐 정도
              offset: Offset(0, -2), // 위쪽으로 살짝 그림자
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Container에서 색 처리했으므로 투명
          elevation: 0, // 내부 elevation 제거
          type: BottomNavigationBarType.fixed,
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/map');
                break;
              case 1:
                Navigator.pushNamed(context, '/chatbot');
                break;
              case 2:
                Navigator.pushNamed(context, '/community');
                break;
              case 3:
                break;
              case 4:
                Navigator.pushNamed(context, '/user');
                break;
            }
          },
          selectedItemColor: Colors.redAccent, // 선택된 아이콘 색
          unselectedItemColor: Colors.grey[300], // 비선택 아이콘 색
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 30),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)),
              label: '재난메뉴',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}
