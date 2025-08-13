import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DisasterType {
  int? id; // 서버가 발급한 id (구독 식별자)
  final String type; // 세부 유형(예: '폭염', '지진')
  bool enabled; // 사용자가 구독 중인지

  DisasterType({this.id, required this.type, this.enabled = false});
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final String baseUrl =
      'http://54.253.211.96:8000/api/notification-disastertypes';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final Map<String, List<String>> categories = const {
    '기상': ['폭염', '한파', '폭설', '강풍', '태풍', '호우', '황사', '미세먼지', '우박', '가뭄'],
    '수해': ['홍수', '하천 범람', '도시 침수', '해일', '쓰나미', '이안류', '폭풍해일'],
    '지질': ['지진', '여진', '화산', '산사태', '싱크홀', '붕괴'],
    '화재·폭발': ['산불', '건물 화재', '가스 폭발', '화학물질 폭발'],
    '유해물질·인프라': [
      '화학물질 유출',
      '방사능 누출',
      '정전',
      '통신 장애',
      '상수도 사고',
      '하수도 사고',
      '가스관 파열',
    ],
    '보건·안전': ['감염병', '식수 오염', '대형 교통사고', '민방위 경보', '실종 아동'],
  };

  final Map<String, IconData> iconMap = const {
    '폭염': Icons.wb_sunny_rounded,
    '한파': Icons.ac_unit_rounded,
    '폭설': Icons.cloud,
    '강풍': Icons.air_rounded,
    '태풍': Icons.air_rounded,
    '호우': Icons.umbrella_rounded,
    '황사': Icons.cloud_rounded,
    '미세먼지': Icons.blur_on_rounded,
    '우박': Icons.grain_rounded,
    '가뭄': Icons.wb_twilight_rounded,

    // 수해
    '홍수': Icons.flood_rounded,
    '하천 범람': Icons.flood_rounded,
    '도시 침수': Icons.flood_rounded,
    '해일': Icons.waves_rounded,
    '쓰나미': Icons.waves_rounded,
    '이안류': Icons.waves_rounded,
    '폭풍해일': Icons.waves_rounded,

    // 지질
    '지진': Icons.warning_amber_rounded,
    '여진': Icons.vibration_rounded,
    '화산': Icons.landscape_rounded,
    '산사태': Icons.terrain_rounded,
    '싱크홀': Icons.warning_amber_rounded,
    '붕괴': Icons.domain_disabled_rounded,

    // 화재·폭발
    '산불': Icons.local_fire_department_rounded,
    '건물 화재': Icons.local_fire_department_rounded,
    '가스 폭발': Icons.bolt_rounded,
    '화학물질 폭발': Icons.science_rounded,

    // 유해물질·인프라
    '화학물질 유출': Icons.science_rounded,
    '방사능 누출': Icons.science_rounded,
    '정전': Icons.power_off_rounded,
    '통신 장애': Icons.signal_cellular_connected_no_internet_4_bar_rounded,
    '상수도 사고': Icons.water_damage_rounded,
    '하수도 사고': Icons.water_drop_rounded,
    '가스관 파열': Icons.tungsten_rounded,

    // 보건·안전
    '감염병': Icons.vaccines_rounded,
    '식수 오염': Icons.water_drop_rounded,
    '대형 교통사고': Icons.directions_car_rounded,
    '민방위 경보': Icons.health_and_safety_rounded,
    '실종 아동': Icons.emergency_rounded,
  };

  final Map<String, Color> colorMap = const {
    '폭염': Colors.orange,
    '한파': Colors.indigo,
    '폭설': Colors.blueGrey,
    '강풍': Colors.lightBlue,
    '태풍': Colors.teal,
    '호우': Colors.blue,
    '황사': Colors.amber,
    '미세먼지': Colors.brown,
    '우박': Colors.cyan,
    '가뭄': Colors.deepOrange,

    '홍수': Colors.blueAccent,
    '하천 범람': Colors.lightBlueAccent,
    '도시 침수': Colors.cyan,
    '해일': Colors.indigoAccent,
    '쓰나미': Colors.indigo,
    '이안류': Colors.teal,
    '폭풍해일': Colors.blueGrey,

    '지진': Colors.orange,
    '여진': Colors.deepOrange,
    '화산': Colors.redAccent,
    '산사태': Colors.brown,
    '싱크홀': Colors.grey,
    '붕괴': Colors.orangeAccent,

    '산불': Colors.redAccent,
    '건물 화재': Colors.red,
    '가스 폭발': Colors.deepOrangeAccent,
    '화학물질 폭발': Colors.purple,

    '화학물질 유출': Colors.deepPurple,
    '방사능 누출': Colors.purpleAccent,
    '정전': Colors.blueGrey,
    '통신 장애': Colors.grey,
    '상수도 사고': Colors.lightBlue,
    '하수도 사고': Colors.blueGrey,
    '가스관 파열': Colors.orange,

    '감염병': Colors.green,
    '식수 오염': Colors.teal,
    '대형 교통사고': Colors.blueGrey,
    '민방위 경보': Colors.amber,
    '실종 아동': Colors.pinkAccent,
  };

  final Map<String, Color> categoryDefaultColor = const {
    '기상': Colors.lightBlue,
    '수해': Colors.teal,
    '지질': Colors.brown,
    '화재·폭발': Colors.red,
    '유해물질·인프라': Colors.deepPurple,
    '보건·안전': Colors.green,
  };

  final Map<String, DisasterType> settingsByType = {};

  String? token;

  @override
  void initState() {
    super.initState();
    initTokenAndFetch();
  }

  Future<void> initTokenAndFetch() async {
    token = await storage.read(key: 'accessToken');

    final headLen = (token ?? '').length >= 12 ? 12 : (token ?? '').length;
    debugPrint(
      'accessToken(head): ${token == null ? 'NULL' : token!.substring(0, headLen)}...',
    );

    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    await fetchUserSettings();
  }

  Future<void> fetchUserSettings() async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);

      final List<String> allSubtypes =
          categories.values.expand((v) => v).toList();

      setState(() {
        settingsByType.clear();

        for (final subtype in allSubtypes) {
          final match = data.cast<Map<String, dynamic>?>().firstWhere(
            (e) => e?['disaster_type'] == subtype,
            orElse: () => null,
          );

          settingsByType[subtype] = DisasterType(
            id: match?['id'],
            type: subtype,
            enabled: match != null,
          );
        }
      });
    } else if (res.statusCode == 401) {
      debugPrint('GET 401: 토큰 만료/무효. 로그인 화면으로 이동');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('세션이 만료되었습니다. 다시 로그인해주세요.')));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      debugPrint('GET 실패: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> toggleDisasterType(DisasterType item) async {
    if (token == null) return;

    if (item.enabled) {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({'disaster_type': item.type}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          item.id = data['id'];
        });
        debugPrint('등록됨: ${item.type}');
      } else if (res.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('세션이 만료되었습니다. 다시 로그인해주세요.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        debugPrint('등록 실패: ${res.statusCode} ${res.body}');
      }
    } else {
      if (item.id != null) {
        final res = await http.delete(
          Uri.parse('$baseUrl/${item.id}'),
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        );

        if (res.statusCode == 200) {
          setState(() {
            item.id = null;
          });
          debugPrint('해제됨: ${item.type}');
        } else if (res.statusCode == 401) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('세션이 만료되었습니다. 다시 로그인해주세요.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          debugPrint('삭제 실패: ${res.statusCode} ${res.body}');
        }
      }
    }
  }

  Widget _buildSubtypeCard({
    required String category,
    required DisasterType item,
  }) {
    final isSelected = item.enabled;

    final Color baseColor =
        isSelected
            ? Colors.red
            : (colorMap[item.type] ??
                categoryDefaultColor[category] ??
                Colors.grey);
    final Color iconColor = isSelected ? Colors.white : baseColor;
    final Color iconBackground =
        isSelected ? Colors.red.withOpacity(0.2) : baseColor.withOpacity(0.15);
    final IconData icon = iconMap[item.type] ?? Icons.warning_amber_rounded;

    return GestureDetector(
      onTap: () {
        setState(() {
          item.enabled = !item.enabled;
        });
        toggleDisasterType(item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12, left: 10, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.type,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    final List<Widget> children = [];

    categories.forEach((categoryName, subtypes) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 8),
          child: Row(
            children: [
              Icon(
                categoryName == '기상'
                    ? Icons.cloud_rounded
                    : categoryName == '수해'
                    ? Icons.flood_rounded
                    : categoryName == '지질'
                    ? Icons.terrain_rounded
                    : categoryName == '화재·폭발'
                    ? Icons.local_fire_department_rounded
                    : categoryName == '유해물질·인프라'
                    ? Icons.science_rounded
                    : Icons.health_and_safety_rounded,
                color: categoryDefaultColor[categoryName] ?? Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: categoryDefaultColor[categoryName] ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );

      for (final subtype in subtypes) {
        final item =
            settingsByType[subtype] ??
            DisasterType(type: subtype, enabled: false);
        children.add(_buildSubtypeCard(category: categoryName, item: item));
      }

      children.add(const SizedBox(height: 8));
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: null,
          centerTitle: true,
          title: const Text(
            '재난 유형 알림 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFDF5F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              '받고 싶은 재난 알림을 선택해주세요',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _buildCategorySections(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF44336), Color(0xFFFF8A65)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '알림 설정 완료',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
