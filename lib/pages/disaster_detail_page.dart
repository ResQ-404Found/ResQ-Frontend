import 'package:flutter/material.dart';
import 'map_page.dart'; // Disaster 클래스 정의된 곳

class DisasterDetailPage extends StatelessWidget {
  final Disaster disaster;

  const DisasterDetailPage({super.key, required this.disaster});

  // 🔥 긴급단계 배너 - 문자열 그대로 출력
  Widget _buildDisasterLevelBanner(String level) {
    return Container(
      width: double.infinity,
      color: Colors.indigo, // 좀 더 안정적인 색감
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          level,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
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
        title: Text('${disaster.region} ${disaster.type}'),
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
                const Text('발생 시각', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(disaster.startTime, style: const TextStyle(color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // 📢 재난 문자
            const SizedBox(height: 12),
            const Text('재난 문자', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (message.trim().isEmpty)
              const Text('📭 재난 문자가 없습니다.', style: TextStyle(color: Colors.grey))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),

            const SizedBox(height: 28),

            // 🧯 대처 방법 이동 버튼
            const Text('대처 방법', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/disasterlist'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F4FF), // 살짝 강조
                  border: Border.all(color: Colors.indigo.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Text('> 자세히 보러 가기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.indigo),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🕓 마지막 업데이트
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