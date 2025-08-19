import 'package:flutter/material.dart';
import 'package:resq_frontend/pages/quiz.dart';

import 'disaster_guide_page.dart';
import 'checklist.dart';
import 'all_disaster_type_detail_page.dart';
import 'app_bottom_nav.dart';
import 'donation_list_page.dart';
import 'news_page.dart'; // ✅ 공통 바텀바 추가

class DisasterMenuPage extends StatelessWidget {
  const DisasterMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': '전체 재난 정보',
        'subtitle': '전체 재난 기록 확인',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.redAccent,
      },
      {
        'title': '대피 방법',
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
      // ✅ 후원 밑에 추가된 항목
      {
        'title': '퀴즈',
        'subtitle': '재난 상식 테스트',
        'icon': Icons.quiz,
        'color': Colors.indigoAccent,
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              key: const PageStorageKey('DisasterMenuList'),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isFirst = index == 0;

                return GestureDetector(
                  onTap: () {
                    final title = item['title'] as String;
                    if (title == '전체 재난 정보') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllDisasterTypeDetailPage(),
                        ),
                      );
                    } else if (title == '대피 방법') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DisasterGuidePage(initialIndex: 0),
                        ),
                      );
                    } else if (title == '체크리스트') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChecklistPage(),
                        ),
                      );
                    } else if (title == '뉴스') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewsPage(),
                        ),
                      );
                    } else if (title == '후원') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DonationListPage(),
                        ),
                      );
                    } else if (title == '퀴즈') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuizPage(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 95,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          width: 52,
                          height: 52,
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
                        const SizedBox(width: 14),
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
                              const SizedBox(height: 2),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
