import 'package:flutter/material.dart';

class DisasterMenuPage extends StatelessWidget {
  const DisasterMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': '재난 정보',
        'subtitle': '실시간 재난 현황 확인',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.redAccent,
      },
      {
        'title': '대처 방법',
        'subtitle': '상황별 대응 가이드',
        'icon': Icons.security,
        'color': Colors.orangeAccent,
      },
      {
        'title': '체크리스트',
        'subtitle': '재난 대비 점검 항목',
        'icon': Icons.check_box,
        'color': Colors.teal,
      },
      {
        'title': '뉴스',
        'subtitle': '재난 관련 최신 소식',
        'icon': Icons.article,
        'color': Colors.blueAccent,
      },
      {
        'title': '후원',
        'subtitle': '재난 구호를 위한 기부',
        'icon': Icons.volunteer_activism,
        'color': Colors.purpleAccent,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 44),
          alignment: Alignment.center,
          child: const Text(
            '재난 대응 메뉴',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isFirst = index == 0;
                  return GestureDetector(
                    onTap: () {
                      if (item['title'] == '대처 방법') {
                        Navigator.pushNamed(context, '/disasterlist');
                      } else if (item['title'] == '체크리스트') {
                        Navigator.pushNamed(context, '/checklist');
                      }
                    },
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: item['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: Colors.white,
                              size: isFirst ? 34 : 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey[300],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: const IconThemeData(size: 30),
          unselectedIconTheme: const IconThemeData(size: 30),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.place),
              ),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.chat),
              ),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.groups),
              ),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.dashboard),
              ),
              label: '재난메뉴',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.favorite_border),
              ),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}
