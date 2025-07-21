import 'package:flutter/material.dart';

/// [DisasterGuidePage]에서 사용할 수 있도록 export 가능한 함수로 분리
Widget buildFireInstructions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),

      // 🔽 제목 아이콘 + 텍스트 한 줄 구성
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 가운데 텍스트
              const Center(
                child: Text(
                  '화재 시 행동요령',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // 아이콘: 왼쪽 끝이 아니라 약간 안쪽으로 오게
              Positioned(
                left: 80, // ← 여기를 조정해서 위치 다듬기
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 24,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 14),

      // 🔽 아래 카드 리스트들
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

      const SizedBox(height: 32),
    ],
  );
}


/// 개별 행동요령 카드 구성
Widget _buildInstructionCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Card(
      color: const Color(0xFFFFE3E3),
        elevation: 3,                   // 그림자 깊이
        shadowColor: Colors.redAccent, // ← 원하는 색으로 설정
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.red.shade800),
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
