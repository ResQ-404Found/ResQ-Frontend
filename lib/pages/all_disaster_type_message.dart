import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllDisasterTypeDetailPage extends StatefulWidget {
  final String disasterType;

  const AllDisasterTypeDetailPage({required this.disasterType, super.key});

  @override
  State<AllDisasterTypeDetailPage> createState() =>
      _AllDisasterTypeDetailPageState();
}

class _AllDisasterTypeDetailPageState
    extends State<AllDisasterTypeDetailPage> {
  List<dynamic> disasters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDisasters();
  }

  Future<void> fetchDisasters() async {
    final url =
        'http://54.253.211.96:8000/api/disasters?disaster_type=${Uri.encodeComponent(widget.disasterType)}&active_only=true';

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
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.disasterType} 정보 기록'),
        actions: const [Icon(Icons.filter_alt_outlined)],
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),


      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : disasters.isEmpty
          ? const Center(child: Text('해당 재난 정보가 없습니다.'))
          : ListView.builder(
        itemCount: disasters.length,
        itemBuilder: (context, index) {
          final item = disasters[index];
          final startTime =
              item['start_time']?.split('T')[0] ?? '날짜 없음';
          final region = item['region_name'] ?? '지역 정보 없음';
          final info = item['info'] ?? '내용 없음';

          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 12),
                  Text(
                    info,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
