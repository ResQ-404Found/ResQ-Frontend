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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: _getLevelColor(level),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text(
            '재난 경보: $level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
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
            // build 내부 중 일부만 발췌 (다음처럼 교체)
            children: [
              _buildDisasterLevelBanner(disaster.disasterLevel),
              const SizedBox(height: 24),

              // 🕒 발생 시각
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 20, color: Colors.indigo),
                  const SizedBox(width: 8),
                  const Text('발생 시각', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 10),
                  Text(
                    disaster.startTime,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),

              // 📢 재난 문자
              const SizedBox(height: 16),
              const Text('📢 재난 문자',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),

              if (message.trim().isEmpty)
                const Text('📭 재난 문자가 없습니다.', style: TextStyle(color: Colors.grey))
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    border: Border.all(color: Colors.indigo.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                ),

              const SizedBox(height: 28),

              // 🧯 대처 방법 버튼
              const Text('📌 대처 방법',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline, color: Colors.black87),
                  label: const Text(
                    '자세히 보러 가기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (routeName.isNotEmpty) {
                      Navigator.pushNamed(context, routeName);
                    } else {
                      Navigator.pushNamed(context, '/disasterlist');
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '⏰ 마지막 업데이트: 1시간 전',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
        ),
      ),
    );
  }
}
