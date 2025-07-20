import 'package:flutter/material.dart';

class LandslidePage extends StatelessWidget {
  const LandslidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text('산사태 대처 방법'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.terrain_rounded,
              size: 100,
              color: Colors.brown.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              '산사태 대비 행동요령',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildInstructionCard(
              icon: Icons.block_rounded,
              title: '비가 많이 오면 산 주변 접근 금지',
              description: '산사태 위험이 높은 날에는 절대 산 주변, 비탈길, 하천 근처에 접근하지 마세요.',
            ),

            _buildInstructionCard(
              icon: Icons.hearing_rounded,
              title: '흙이 무너지는 소리에 주의',
              description: '비 오는 날 갑작스러운 굉음이나 땅 울림, 나무 부러지는 소리가 들리면 즉시 위험을 감지하세요.',
            ),

            _buildInstructionCard(
              icon: Icons.arrow_upward_rounded,
              title: '즉시 높은 곳으로 대피',
              description: '산사태 징후가 보이면 즉시 반대 방향의 높은 지대로 신속히 이동하세요.',
            ),

            _buildInstructionCard(
              icon: Icons.warning_amber_rounded,
              title: '산사태 지역에서 머무르지 않기',
              description: '피해 발생 지역 주변에는 추가 산사태 위험이 있으므로 머무르지 마세요.',
            ),

            _buildInstructionCard(
              icon: Icons.phone_in_talk_rounded,
              title: '긴급 신고 및 가족에게 알리기',
              description: '119 또는 지자체에 위험 상황을 알리고, 가족이나 이웃에게도 즉시 상황을 공유하세요.',
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
              Icon(icon, size: 36, color: Colors.brown.shade800),
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
