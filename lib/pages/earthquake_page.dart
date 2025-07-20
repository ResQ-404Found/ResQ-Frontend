import 'package:flutter/material.dart';

class EarthquakePage extends StatelessWidget {
  const EarthquakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('지진 대처 방법'),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              '지진 대비 행동요령',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildInstructionCard(
              icon: Icons.table_bar_rounded,
              title: '탁자 밑으로 들어가 머리 보호',
              description: '진동이 시작되면 단단한 탁자 밑으로 들어가 두 손으로 머리와 목을 감싸고 보호하세요.',
            ),

            _buildInstructionCard(
              icon: Icons.chair_alt_rounded,
              title: '떨어지는 물건 주의',
              description: '진동 중에는 유리, 액자, 천장등, 가전제품 등 떨어질 수 있는 물건에서 떨어지세요.',
            ),

            _buildInstructionCard(
              icon: Icons.directions_run_rounded,
              title: '진동 멈춘 후 대피',
              description: '지진이 멈춘 후 침착하게 출입문을 열고, 계단을 이용해 밖으로 대피하세요. 엘리베이터는 절대 금지!',
            ),

            _buildInstructionCard(
              icon: Icons.waves_rounded,
              title: '해안가에서는 고지대로 대피',
              description: '해안 근처에 있다면 즉시 높은 지대로 이동하세요. 지진 후 쓰나미가 발생할 수 있습니다.',
            ),

            _buildInstructionCard(
              icon: Icons.lightbulb_rounded,
              title: '전기·가스 차단',
              description: '화재를 방지하기 위해 전기 스위치와 가스 밸브를 차단하세요.',
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
              Icon(icon, size: 36, color: Colors.orange.shade800),
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