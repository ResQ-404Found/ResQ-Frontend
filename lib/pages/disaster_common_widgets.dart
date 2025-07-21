import 'package:flutter/material.dart';

/// 공통 행동요령 레이아웃
Widget buildDisasterInstructions({
  required String disasterName,
  required IconData icon,
  required Color color,
  required List<Map<String, String>> instructions,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
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
                  backgroundColor: color.withOpacity(0.1),
                  radius: 20,
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: disasterName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const TextSpan(
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

            // 카드 목록
            for (final step in instructions)
              _buildInstructionCard(
                icon: IconData(int.parse(step['iconCode']!), fontFamily: 'MaterialIcons'),
                title: step['title']!,
                description: step['description']!,
                color: color,
              ),
          ],
        ),
      ),
    ),
  );
}

/// 개별 행동요령 카드
Widget _buildInstructionCard({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
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
