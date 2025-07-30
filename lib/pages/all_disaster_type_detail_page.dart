import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllDisasterTypeDetailPage extends StatefulWidget {
  const AllDisasterTypeDetailPage({super.key});

  @override
  State<AllDisasterTypeDetailPage> createState() =>
      _AllDisasterTypeDetailPageState();
}

class _AllDisasterTypeDetailPageState extends State<AllDisasterTypeDetailPage> {
  final List<String> disasterTypes = [
    '전체',
    '화재',
    '산사태',
    '홍수',
    '지진',
    '태풍',
    '호우',
    '강풍',
    '황사',
    '해일',
    '폭염',
    '한파',
    '대설',
    '가뭄',
    '산불',
    '붕괴',
    '전기/가스 사고',
    '환경오염 사고',
    '유해물질 누출',
    '교통사고',
    '테러/전쟁/범죄',
  ];

  final Map<String, IconData> iconMap = {
    '전체': Icons.all_inclusive,
    '화재': Icons.local_fire_department_rounded,
    '산사태': Icons.terrain_rounded,
    '홍수': Icons.flood_rounded,
    '지진': Icons.warning_amber_rounded,
    '태풍': Icons.air_rounded,
    '호우': Icons.cloud,
    '강풍': Icons.wind_power,
    '황사': Icons.cloudy_snowing,
    '해일': Icons.waves,
    '폭염': Icons.sunny,
    '한파': Icons.ac_unit_rounded,
    '대설': Icons.snowing,
    '가뭄': Icons.opacity,
    '산불': Icons.local_fire_department,
    '붕괴': Icons.cabin,
    '전기/가스 사고': Icons.bolt,
    '환경오염 사고': Icons.eco,
    '유해물질 누출': Icons.science,
    '교통사고': Icons.car_crash,
    '테러/전쟁/범죄': Icons.shield,
    '기타': Icons.more_horiz,
  };

  final Map<String, Color> colorMap = {
    '전체': Colors.black,
    '화재': Colors.red,
    '산사태': Colors.brown,
    '홍수': Colors.blue,
    '지진': Colors.orange,
    '태풍': Colors.teal,
    '호우': Colors.lightBlue,
    '강풍': Colors.green,
    '황사': Colors.amber,
    '해일': Colors.cyan,
    '폭염': Colors.deepOrange,
    '한파': Colors.indigo,
    '대설': Colors.lightBlueAccent,
    '가뭄': Colors.brown,
    '산불': Colors.deepOrange,
    '붕괴': Colors.grey,
    '전기/가스 사고': Colors.deepPurple,
    '환경오염 사고': Colors.green,
    '유해물질 누출': Colors.deepOrange,
    '교통사고': Colors.blueGrey,
    '테러/전쟁/범죄': Colors.black,
    '기타': Colors.grey,
  };

  String selectedType = '전체';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey, // 그림자 색
                blurRadius: 2, // 퍼짐 정도
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            scrolledUnderElevation: 0,
            elevation: 0, // 기본 그림자 제거
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(
              '전체 재난정보',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 35),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 그림자 색상 (연하게)
                  blurRadius: 2, // 그림자 퍼짐 정도
                  offset: const Offset(0, 0.1), // 아래로 약간 그림자
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(
                        iconMap[selectedType] ?? Icons.info,
                        color: colorMap[selectedType] ?? Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$selectedType 재난 문자',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    child: const Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.black87,
                      size: 28,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                clipBehavior: Clip.antiAlias, // 💥 꼭 추가
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 500,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    // 여긴 borderRadius 필요 없음 (Material에 이미 있음)
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        color: Colors.grey[100],
                                        padding: const EdgeInsets.only(
                                          top: 22,
                                          bottom: 12,
                                        ),
                                        child: Column(
                                          children: [
                                            const Text(
                                              '재난 유형 변경',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ), // 텍스트와 Divider 사이 공백
                                            // const Divider(height: 1, thickness: 0.5),
                                          ],
                                        ),
                                      ),

                                      Flexible(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: disasterTypes.length,
                                          itemBuilder: (context, index) {
                                            final type = disasterTypes[index];
                                            final icon =
                                                iconMap[type] ??
                                                Icons.more_horiz;
                                            final color =
                                                colorMap[type] ?? Colors.grey;

                                            return Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 8.0,
                                                      ),
                                                  child: ListTile(
                                                    tileColor: Colors.white,
                                                    leading: Icon(
                                                      icon,
                                                      color: color,
                                                    ),
                                                    title: Text(
                                                      type,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            type == selectedType
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        color:
                                                            type == selectedType
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[600],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        selectedType = type;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  thickness: 0.5,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DisasterTypeDetailView(
              disasterType: selectedType,
              iconMap: iconMap,
              colorMap: colorMap,
            ),
          ),
        ],
      ),
    );
  }
}

class DisasterTypeDetailView extends StatefulWidget {
  final String disasterType;
  final Map<String, IconData> iconMap;
  final Map<String, Color> colorMap;

  const DisasterTypeDetailView({
    super.key,
    required this.disasterType,
    required this.iconMap,
    required this.colorMap,
  });

  @override
  State<DisasterTypeDetailView> createState() => _DisasterTypeDetailViewState();
}

class _DisasterTypeDetailViewState extends State<DisasterTypeDetailView> {
  List<dynamic> disasters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDisasters();
  }

  @override
  void didUpdateWidget(covariant DisasterTypeDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.disasterType != widget.disasterType) {
      fetchDisasters();
    }
  }

  Future<void> fetchDisasters() async {
    setState(() {
      isLoading = true;
    });

    final baseUrl = 'http://54.253.211.96:8000/api/disasters';
    final url =
        widget.disasterType == '전체'
            ? '$baseUrl?active_only=true'
            : '$baseUrl?disaster_type=${Uri.encodeComponent(widget.disasterType)}&active_only=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded['data'];

        final List<dynamic> allDisasters = [];
        for (var item in rawList) {
          if (item['disasters'] is List) {
            allDisasters.addAll(item['disasters']);
          }
        }

        setState(() {
          disasters = allDisasters;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildIconForType(String disasterType) {
    final icon = widget.iconMap[disasterType] ?? Icons.more_horiz;
    final color = widget.colorMap[disasterType] ?? Colors.grey;
    return Icon(icon, color: color, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (disasters.isEmpty) {
      return const Center(child: Text('해당 재난 정보가 없습니다.'));
    }

    return ListView.builder(
      itemCount: disasters.length,
      itemBuilder: (context, index) {
        final item = disasters[index];
        final rawTime = item['start_time'] ?? '';
        String startTimeFormatted = '시간 없음';
        if (rawTime.contains('T')) {
          final parts = rawTime.split('T');
          final date = parts[0];
          final time = parts[1].substring(0, 5); // '11:44' 형식
          startTimeFormatted = '$date $time';
        }

        final region = item['region_name'] ?? '지역 정보 없음';
        final info = item['info'] ?? '내용 없음';
        final type = (item['disaster_type'] as String?)?.trim() ?? '기타';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 2),
                    child: _buildIconForType(type),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          startTimeFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          region,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
