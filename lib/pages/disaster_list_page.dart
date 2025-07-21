import 'package:flutter/material.dart';
import 'disaster_guide_page.dart'; // 통합 가이드 페이지 import

class DisasterListPage extends StatelessWidget {
  const DisasterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final disasterTypes = [
      {'title': '화재', 'icon': Icons.local_fire_department_rounded, 'color': Colors.red},
      {'title': '산사태', 'icon': Icons.terrain_rounded, 'color': Colors.brown},
      {'title': '홍수', 'icon': Icons.flood_rounded, 'color': Colors.blue},
      {'title': '태풍', 'icon': Icons.air_rounded, 'color': Colors.teal},
      {'title': '지진', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
      {'title': '한파', 'icon': Icons.ac_unit_rounded, 'color': Colors.indigo},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('대처 방법 목록'),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: disasterTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final disaster = disasterTypes[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // 선택된 재난 인덱스를 넘겨서 DisasterGuidePage로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DisasterGuidePage(initialIndex: index),
                  ),
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(disaster['icon'] as IconData, size: 36, color: disaster['color'] as Color),
                    const SizedBox(height: 12),
                    Text(
                      disaster['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
