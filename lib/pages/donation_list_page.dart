import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Donation {
  final int id;
  final String title;
  final String sponsorName;
  final String disasterType;
  final String content;
  final String startDate;
  final String dueDate;
  final int targetMoney;
  final int currentMoney;
  final String imageUrl;

  Donation({
    required this.id,
    required this.title,
    required this.sponsorName,
    required this.disasterType,
    required this.content,
    required this.startDate,
    required this.dueDate,
    required this.targetMoney,
    required this.currentMoney,
    required this.imageUrl,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      title: json['title'],
      sponsorName: json['sponsor_name'],
      disasterType: json['disaster_type'],
      content: json['content'],
      startDate: json['start_date'],
      dueDate: json['due_date'],
      targetMoney: json['target_money'],
      currentMoney: json['current_money'],
      imageUrl: json['image_url'],
    );
  }

  double get progress => currentMoney / (targetMoney == 0 ? 1 : targetMoney);
}

class DonationListPage extends StatefulWidget {
  @override
  State<DonationListPage> createState() => _DonationListPageState();
}

class _DonationListPageState extends State<DonationListPage> {
  Future<List<Donation>> fetchDonations() async {
    final response = await http.get(Uri.parse('http://54.253.211.96:8000/api/sponsor'));
    if (response.statusCode == 200) {
      List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Donation.fromJson(e)).toList();
    } else {
      throw Exception('후원 목록 불러오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('후원 목록', style: TextStyle(fontWeight: FontWeight.bold))),
      body: FutureBuilder<List<Donation>>(
        future: fetchDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('에러: ${snapshot.error}'));
          final donations = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final d = donations[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/detail', arguments: d),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: EdgeInsets.only(bottom: 20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(d.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('${d.disasterType}', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                                SizedBox(width: 8),
                                Text('~ ${d.dueDate}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(d.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(d.sponsorName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text('${d.currentMoney ~/ 10000}만원', style: TextStyle(fontWeight: FontWeight.bold)),
                                Spacer(),
                                Text('목표 ${d.targetMoney ~/ 10000}만원', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: d.progress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blue,
                              minHeight: 6,
                            ),
                            SizedBox(height: 8),
                            Text('${(d.progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/detail', arguments: d),
                                child: Text('후원하기'),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
