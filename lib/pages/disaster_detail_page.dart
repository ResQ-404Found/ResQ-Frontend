import 'package:flutter/material.dart';
import 'map_page.dart'; // Disaster 클래스 정의된 곳

class DisasterDetailPage extends StatelessWidget {
  final Disaster disaster;

  const DisasterDetailPage({super.key, required this.disaster});

  Color _getLevelColor(String level) {
    switch (level) {
      case '심각':
        return Colors.red.shade700;
      case '경계':
        return Colors.orange.shade600;
      case '주의':
        return Colors.amber.shade600;
      case '관심':
        return Colors.green.shade600;
      default:
        return Colors.indigo;
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
        return '/disasterlist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageList = disaster.info
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final routeName = _getRouteByType(disaster.type);

    return Scaffold(
      backgroundColor: Colors.white, // ✅ 전체 배경 흰색
      appBar: AppBar(
        title: Text(
          '${disaster.region} ${disaster.type}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔴 긴급단계 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _getLevelColor(disaster.disasterLevel),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    '긴급단계',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disaster.disasterLevel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🕒 발생 시각
            Row(
              children: [
                const Text(
                  '발생 시각',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Text(
                  disaster.startTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 1),

            // 📢 재난 문자
            const SizedBox(height: 16),
            const Text(
              '재난 문자',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...messageList.map((msg) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            )),

            const SizedBox(height: 28),

            const Text(
              '대처 방법',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 🧯 대처 방법 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, routeName);
                },
                icon: const Icon(Icons.info_outline, color: Colors.black87),
                label: const Text(
                  '자세히 보러 가기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Center(
              child: Text(
                '마지막 업데이트: 1시간 전',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
