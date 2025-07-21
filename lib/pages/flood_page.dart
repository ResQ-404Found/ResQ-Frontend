import 'package:flutter/material.dart';

/// 홍수 대처 방법 콘텐츠 위젯 함수
Widget buildFloodInstructions() {
  return Column(
    children: [
      const SizedBox(height: 24),
      Icon(
        Icons.flood_rounded,
        size: 100,
        color: Colors.blueGrey.shade400,
      ),
      const SizedBox(height: 10),
      const Text(
        '홍수 대비 행동요령',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      _buildInstructionCard(
        icon: Icons.cloud_rounded,
        title: '기상정보 수시 확인',
        description: '기상청과 행정안전부 알림 등을 통해 홍수 경보, 예보 정보를 수시로 확인하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.landscape_rounded,
        title: '저지대 및 하천 주변 피하기',
        description: '하천 근처, 산사태 우려 지역, 침수 위험이 있는 지하실 등은 피하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.power_off_rounded,
        title: '전기 차단 후 대피',
        description: '감전 사고를 방지하기 위해 반드시 차단기를 내리고 대피하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.directions_car_filled_rounded,
        title: '차량 침수 시 즉시 탈출',
        description: '물에 잠기기 시작한 차량 안에 있지 말고 즉시 문을 열고 밖으로 탈출하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.health_and_safety_rounded,
        title: '감염병 예방',
        description: '침수 지역을 다녀온 후에는 손을 씻고, 오염된 음식이나 물을 피하세요.',
      ),
      const SizedBox(height: 32),
    ],
  );
}

/// 카드 UI 재사용 함수
Widget _buildInstructionCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.blueGrey.shade800),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
