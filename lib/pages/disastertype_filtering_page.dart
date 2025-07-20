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
      appBar: AppBar(
        title: const Text('재난 문자 설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: settings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: settings.length,
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            title: Text(item.type, style: const TextStyle(fontSize: 18)),
            trailing: Switch(
              value: item.enabled,
              onChanged: (bool newValue) {
                setState(() {
                  item.enabled = newValue;
                });
                toggleDisasterType(item);
              },
            ),
          );
        },
      ),
    );
  }
}
