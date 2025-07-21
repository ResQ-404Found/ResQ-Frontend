import 'package:flutter/material.dart';

// 각 재난별 콘텐츠 함수 import
import 'fire_page.dart';
import 'flood_page.dart';
import 'earthquake_page.dart';
import 'coldwave_page.dart';
import 'landslide_page.dart';
import 'typhoon_page.dart';

class DisasterGuidePage extends StatefulWidget {
  final int initialIndex;
  const DisasterGuidePage({super.key, this.initialIndex = 0});

  @override
  State<DisasterGuidePage> createState() => _DisasterGuidePageState();
}

class _DisasterGuidePageState extends State<DisasterGuidePage> {
  late int _selectedIndex;

  final disasterTypes = [
    {'title': '화재', 'icon': Icons.local_fire_department_rounded, 'color': Colors.red},
    {'title': '산사태', 'icon': Icons.terrain_rounded, 'color': Colors.brown},
    {'title': '홍수', 'icon': Icons.flood_rounded, 'color': Colors.blue},
    {'title': '태풍', 'icon': Icons.air_rounded, 'color': Colors.teal},
    {'title': '지진', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
    {'title': '한파', 'icon': Icons.ac_unit_rounded, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget getCurrentContent() {
    switch (_selectedIndex) {
      case 0:
        return buildFireInstructions();
      case 1:
        return buildLandslideInstructions();
      case 2:
        return buildFloodInstructions();
      case 3:
        return buildTyphoonInstructions();
      case 4:
        return buildEarthquakeInstructions();
      case 5:
        return buildColdwaveInstructions();
      default:
        return const Center(child: Text("알 수 없는 재난"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = disasterTypes[_selectedIndex]['color'] as Color;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
        title: const Text('재난 대처 방법'),
        backgroundColor: Color(0xFFFF3F3F),
        foregroundColor: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFFfafafa),
      body: Column(
        children: [
          SizedBox(height: 10),
          // 상단 재난 선택 탭
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: List.generate(disasterTypes.length, (index) {
                  final type = disasterTypes[index];
                  final selected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? (type['color'] as Color).withOpacity(0.15)
                            : Colors.white,
                        border: Border.all(
                          color: selected
                              ? type['color'] as Color
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 18,
                            color: type['color'] as Color, // 아이콘은 여전히 색 유지
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black, //글자는 항상 검정색
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                }),
              ),
            ),
          ),


          // 선택된 재난 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              child: getCurrentContent(),
            ),
          ),
        ],
      ),
    );
  }
}
