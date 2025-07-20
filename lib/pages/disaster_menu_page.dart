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
    );
  }
}
