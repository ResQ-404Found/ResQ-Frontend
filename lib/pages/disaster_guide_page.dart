import 'package:flutter/material.dart';
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
    {
      'title': '화재',
      'icon': Icons.local_fire_department_rounded,
      'color': Colors.red
    },
    {'title': '산사태', 'icon': Icons.terrain_rounded, 'color': Colors.brown},
    {'title': '홍수', 'icon': Icons.flood_rounded, 'color': Colors.blue},
    {'title': '태풍', 'icon': Icons.air_rounded, 'color': Colors.teal},
    {
      'title': '지진',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange
    },
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
      backgroundColor: const Color(0xFFfafafa),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40), // 상태바 높이 보정
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
                                color: type['color'] as Color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                type['title'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80), // 버튼과 겹치지 않게 여백
                  child: getCurrentContent(),
                ),
              ),
            ],
          ),

          // 오른쪽 하단 돌아가기 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
