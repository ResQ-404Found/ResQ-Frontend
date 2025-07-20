import 'package:flutter/material.dart';

class DisasterListPage extends StatelessWidget {
  const DisasterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final disasterTypes = [
      {'title': '화재', 'route': '/fire', 'icon': Icons.local_fire_department_rounded, 'color': Colors.red},
      {'title': '산사태', 'route': '/landslide', 'icon': Icons.terrain_rounded, 'color': Colors.brown},
      {'title': '홍수', 'route': '/flood', 'icon': Icons.flood_rounded, 'color': Colors.blue},
      {'title': '태풍', 'route': '/typhoon', 'icon': Icons.air_rounded, 'color': Colors.teal},
      {'title': '지진', 'route': '/earthquake', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
      {'title': '한파', 'route': '/coldwave', 'icon': Icons.ac_unit_rounded, 'color': Colors.indigo},
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: disasterTypes.length,
        itemBuilder: (context, index) {
          final disaster = disasterTypes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, disaster['route'] as String),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        disaster['icon'] as IconData,
                        size: 28,
                        color: disaster['color'] as Color,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        disaster['title'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
