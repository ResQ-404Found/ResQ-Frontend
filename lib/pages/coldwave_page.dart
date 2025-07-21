import 'package:flutter/material.dart';

/// 한파 대처 방법 콘텐츠 위젯 함수
Widget buildColdwaveInstructions() {
  return Column(
    children: [
      const SizedBox(height: 24),
      Icon(
        Icons.ac_unit_rounded,
        size: 100,
        color: Colors.blue.shade300,
      ),
      const SizedBox(height: 10),
      const Text(
        '한파 대비 행동요령',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      _buildInstructionCard(
        icon: Icons.checkroom_rounded,
        title: '따뜻한 옷을 입고 외출 자제',
        description: '기온이 급격히 낮아지므로 외출은 자제하고, 외출 시에는 목도리, 장갑, 모자 등을 착용해 체온을 유지하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.water_damage_rounded,
        title: '수도관 동파 예방',
        description: '수도계량기와 배관에 보온재를 감싸고, 장시간 외출 시 수돗물을 조금 틀어 놓아 동파를 방지하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.fireplace_rounded,
        title: '난방기기 안전 점검',
        description: '전기장판, 온풍기, 난로 등은 과열, 누전 위험이 있으므로 주기적으로 점검하고 안전하게 사용하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.volunteer_activism_rounded,
        title: '노약자 및 이웃 돌보기',
        description: '혼자 사는 어르신, 거동이 불편한 이웃이 있는지 확인하고 필요한 도움을 주세요.',
      ),
      _buildInstructionCard(
        icon: Icons.health_and_safety_rounded,
        title: '건강관리 및 저체온증 예방',
        description: '무리한 실외 활동을 피하고, 실내 온도는 18~20도 이상을 유지하며, 따뜻한 음식을 섭취하세요.',
      ),
      _buildInstructionCard(
        icon: Icons.school_rounded,
        title: '어린이 및 학생 보호',
        description: '등하교 시 따뜻한 복장을 착용하고, 학교에서 난방이 잘 되는지 확인해 주세요.',
      ),
      const SizedBox(height: 32),
    ],
  );
}

/// 공통 카드 구성 함수
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
            Icon(icon, size: 36, color: Colors.blue.shade700),
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
