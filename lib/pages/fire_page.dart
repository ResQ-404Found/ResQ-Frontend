import 'package:flutter/material.dart';

class FirePage extends StatelessWidget {
  const FirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('화재 대피 방법'),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.local_fire_department_rounded,
              size: 100,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              '화재 시 행동요령',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

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
        ),
      ),
    );
  }

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
}
