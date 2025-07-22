import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DisasterType {
  int? id;
  final String type;
  bool enabled;

  DisasterType({this.id, required this.type, this.enabled = false});
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final String baseUrl = 'http://54.253.211.96:8000/api/notification-disastertypes';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final List<String> allTypes = ['화재', '산사태','홍수', '태풍','지진','한파'];
  final Map<String, IconData> iconMap = {
    '화재': Icons.local_fire_department_rounded,
    '산사태': Icons.terrain_rounded,
    '홍수': Icons.flood_rounded,
    '태풍': Icons.air_rounded,
    '지진': Icons.warning_amber_rounded,

    '한파': Icons.ac_unit_rounded,

  };

  final Map<String, Color> colorMap = {
    '화재': Colors.red,
    '산사태': Colors.brown,
    '홍수': Colors.blue,
    '태풍': Colors.teal,
    '지진': Colors.orange,

    '한파': Colors.indigo,

  };

  List<DisasterType> settings = [];
  String? token;

  @override
  void initState() {
    super.initState();
    initTokenAndFetch();
  }

  Future<void> initTokenAndFetch() async {
    token = await storage.read(key: 'accessToken');
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
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      setState(() {
        settings = allTypes.map((type) {
          final match = data.firstWhere(
                (e) => e['disaster_type'] == type,
            orElse: () => null,
          );

          return DisasterType(
            id: match?['id'],
            type: type,
            enabled: match != null,
          );
        }).toList();
      });
    } else {
      print('❌ GET 실패: ${res.statusCode}');
    }
  }

  Future<void> toggleDisasterType(DisasterType item) async {
    if (token == null) return;

    if (item.enabled) {
      // ✅ POST
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'disaster_type': item.type}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          item.id = data['id'];
        });
        print('✅ 등록됨: ${item.type}');
      } else {
        print('❌ 등록 실패: ${res.statusCode}');
      }
    } else {
      // ✅ DELETE
      if (item.id != null) {
        final res = await http.delete(
          Uri.parse('$baseUrl/${item.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (res.statusCode == 200) {
          setState(() {
            item.id = null;
          });
          print('🗑️ 해제됨: ${item.type}');
        } else {
          print('❌ 삭제 실패: ${res.statusCode}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  final item = settings[index];
                  final isSelected = item.enabled;

                  final baseColor = isSelected ? Colors.red : (colorMap[item.type] ?? Colors.grey);
                  final iconColor = isSelected ? Colors.white : baseColor;
                  final iconBackground = isSelected
                      ? Colors.red.withOpacity(0.2)
                      : baseColor.withOpacity(0.15);
                  final icon = iconMap[item.type] ?? Icons.warning;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item.enabled = !item.enabled;
                      });
                      toggleDisasterType(item);
                    },
                    child: AnimatedContainer( // ✅ 변경됨
                      duration: const Duration(milliseconds: 250), // ✅ 애니메이션 시간
                      curve: Curves.easeInOut, // ✅ 부드러운 곡선
                      margin: const EdgeInsets.only(bottom: 16, left: 10, right: 10),
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

                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white, // ✅ 흰 배경 추가
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
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
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