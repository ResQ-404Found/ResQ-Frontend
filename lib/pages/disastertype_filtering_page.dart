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

  final List<String> allTypes = ['화재', '지진', '홍수', '태풍', '한파', '산사태'];

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
      // 앱 바를 감싸는 Container에 바깥쪽 그림자 추가
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // 앱 바 크기 줄이기
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 앱 바의 배경을 흰색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // 그림자의 색상
                spreadRadius: 1, // 그림자의 크기
                blurRadius: 6, // 흐림 정도
                offset: const Offset(0, 4), // 그림자의 위치 (아래쪽)
              ),
            ],
          ),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(top: 20), // 화살표 위치 조정

              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 35),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor: Colors.white, // 앱 바의 배경을 흰색으로 설정
            foregroundColor: Colors.black,
            elevation: 0,  // 내부 그림자 제거
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 20.0), // 텍스트와 아이콘을 동일하게 맞추기 위한 위쪽 여백 추가
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.only(top: 3), // 글자 위치 조금만 올리기
                  child: Text(
                    '재난 문자 설정',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: settings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
        margin: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!, width: 0.5),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true, // <- 이거 추가!
          physics: const NeverScrollableScrollPhysics(), // 만약 안에서만 스크롤 막고 싶다면 추가
          itemCount: settings.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.withOpacity(0.4),
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final item = settings[index];
            return ListTile(
              title: Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: (index == settings.length - 1) ? 20.0 : 0.0),
                child: Text(item.type, style: const TextStyle(fontSize: 18)),
              ),


              trailing: Switch(
                value: item.enabled,
                onChanged: (bool newValue) {
                  setState(() {
                    item.enabled = newValue;
                  });
                  toggleDisasterType(item);
                },
                activeColor: Colors.red,
                inactiveTrackColor: Colors.grey[400],
                inactiveThumbColor: Colors.grey[700],
              ),
            );
          },
        ),
      ),

    );
  }
}
