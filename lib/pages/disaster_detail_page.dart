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

  Widget _buildDisasterLevelBanner(String level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withOpacity(1), // ✅ 살짝 투명하게
        borderRadius: BorderRadius.circular(16),        // ✅ 더 둥글게
      ),
      child: Center(
        child: Text(
          level,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
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
      appBar: AppBar(
        title: Text(
          '${disaster.region} ${disaster.type}',
          style: const TextStyle(
            fontWeight: FontWeight.w900, // 살짝 볼드
            fontSize: 20,                // (선택) 원하는 크기로 조절
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisasterLevelBanner(disaster.disasterLevel),
            const SizedBox(height: 24),

            // 🕒 발생 시각
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text('발생 시각', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                Text(disaster.startTime, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // 📢 재난 문자
            const SizedBox(height: 16),
            const Text('재난 문자',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            if (message.trim().isEmpty)
              const Text('재난 문자가 없습니다.',
                  style: TextStyle(color: Colors.grey))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 28),

            // 🧯 대처 방법 이동 버튼
            const Text('대처 방법',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            InkWell(
              onTap: () {
                if (routeName.isNotEmpty) {
                  Navigator.pushNamed(context, routeName);
                } else {
                  Navigator.pushNamed(context, '/disasterlist');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 18, color: Colors.indigo),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '자세히 보러 가기',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.indigo),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Center(
              child: Text(
                '마지막 업데이트: 1시간 전',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
