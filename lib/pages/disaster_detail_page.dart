import 'package:flutter/material.dart';
import 'map_page.dart'; // Disaster 클래스 정의된 곳

class DisasterDetailPage extends StatelessWidget {
  final Disaster disaster;

  const DisasterDetailPage({super.key, required this.disaster});

  Color _getLevelColor(String level) {
    switch (level) {
      default:
        return Colors.red.shade700;
    }
  }

  String _getRouteByType(String type) {
    switch (type) {
      case '화재':
        return '/fire';
      case '산사태':
        return '/landslide';
      case '홍수':
        return '/flood';
      case '태풍':
        return '/typhoon';
      case '지진':
        return '/earthquake';
      case '한파':
        return '/coldwave';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String message = disaster.info;
    final String routeName = _getRouteByType(disaster.type);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 4,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15), // ← 여기서 값 조절 (기본은 0)
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          '${disaster.region} ${disaster.type}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 안내 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _getLevelColor(disaster.disasterLevel),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.notifications_active, size: 36, color: Colors.white),
                  SizedBox(height: 4),
                  Text(
                    '안전안내',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '진행 중',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🕒 발생 시각 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCCCC)), // 🔴 테두리 색 수정
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.red), // 🔴 아이콘 색 변경
                  const SizedBox(width: 8),
                  const Text(
                    '발생 시간',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    disaster.startTime,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📢 재난 문자 내용
            const Text(
              '재난 문자',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFFCCCC)), // 🔴 테두리 색 수정
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),

            // 🧯 대처 방법 이동 버튼
            InkWell(
              onTap: () {
                if (routeName.isNotEmpty) {
                  Navigator.pushNamed(context, routeName);
                } else {
                  Navigator.pushNamed(context, '/disasterlist');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFFCCCC)), // 🔴 테두리 색 수정
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 18, color: Colors.red), // 🔴 아이콘 색 변경
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '대처 방법',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red), // 🔴 아이콘 색 변경
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                '마지막 업데이트: 1시간 전',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
