import 'package:flutter/material.dart';

class TyphoonPage extends StatelessWidget {
  const TyphoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('태풍 대처 방법'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.air_rounded,
              size: 100,
              color: Colors.teal.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              '태풍 대비 행동요령',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildInstructionCard(
              icon: Icons.window_rounded,
              title: '창문, 출입문 단단히 고정',
              description: '강풍에 대비해 창문과 출입문을 테이프나 못 등으로 단단히 고정하고, 유리 파편 방지를 위해 커튼을 쳐두세요.',
            ),

            _buildInstructionCard(
              icon: Icons.home_rounded,
              title: '외출 삼가, 실내 대피',
              description: '태풍 경보 시에는 외출을 삼가고 실내에서 대피 장소를 미리 확인하세요.',
            ),

            _buildInstructionCard(
              icon: Icons.block_flipped,
              title: '침수지역 접근 금지',
              description: '하천, 해안도로, 지하차도 등 침수 위험 지역은 절대 접근하지 마세요.',
            ),

            _buildInstructionCard(
              icon: Icons.wifi_tethering_rounded,
              title: '기상정보 수시 확인',
              description: '기상청, 재난알림 앱 등을 통해 태풍의 이동 경로와 속도를 실시간으로 확인하세요.',
            ),

            _buildInstructionCard(
              icon: Icons.power_settings_new_rounded,
              title: '전기 및 가스 점검',
              description: '정전이나 누전 위험을 방지하기 위해 가전제품 플러그를 뽑고 가스 밸브를 점검하세요.',
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
              Icon(icon, size: 36, color: Colors.teal.shade800),
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
