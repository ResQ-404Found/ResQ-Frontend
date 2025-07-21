import 'package:flutter/material.dart';

Widget buildFireInstructions() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 아이콘 + 제목
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade50,
                  radius: 20,
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '화재',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // 🔴 강조
                        ),
                      ),
                      TextSpan(
                        text: ' 시 행동요령',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 카드 리스트
            _buildInstructionCard(
              icon: Icons.campaign_rounded,
              title: '“불이야!”라고 외친다',
              description: '주변 사람들에게 위험을 알리고 신속히 대피할 수 있도록 소리쳐서 알리세요.',
            ),
            _buildInstructionCard(
              icon: Icons.masks_rounded,
              title: '젖은 수건으로 코와 입을 막는다',
              description: '연기 흡입을 방지하기 위해 젖은 수건이나 옷으로 코와 입을 막아 호흡을 최소화하세요.',
            ),
            _buildInstructionCard(
              icon: Icons.arrow_downward_rounded,
              title: '낮은 자세로 이동한다',
              description: '연기는 위로 올라가기 때문에 바닥에 최대한 낮게 몸을 숙여 이동하세요.',
            ),
            _buildInstructionCard(
              icon: Icons.exit_to_app_rounded,
              title: '건물 밖으로 신속히 대피한다',
              description: '비상구나 계단을 이용하여 엘리베이터가 아닌 계단으로 대피하세요.',
            ),
            _buildInstructionCard(
              icon: Icons.call_rounded,
              title: '119에 신고한다',
              description: '안전한 장소로 이동 후, 119에 화재 사실과 위치를 신속히 신고하세요.',
            ),
          ],
        ),
      ),
    ),
  );
}


/// 개별 행동요령 카드 구성
Widget _buildInstructionCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
