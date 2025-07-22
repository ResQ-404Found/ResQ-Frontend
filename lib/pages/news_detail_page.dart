import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

class NewsDetailPage extends StatefulWidget {
  final int newsId;

  const NewsDetailPage({super.key, required this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  Map<String, dynamic>? newsDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewsDetail();
  }

  Future<void> fetchNewsDetail() async {
    final url = Uri.parse(
      'http://54.253.211.96:8000/api/news/${widget.newsId}',
    );
    final response = await http.get(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        newsDetail = data;
        isLoading = false;
      });
    } else {
      print('상세 뉴스 불러오기 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('뉴스 상세'), backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsDetail?['title'] ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (newsDetail?['pub_date'] as String?)?.replaceAll(
                            'T',
                            ' ',
                          ) ??
                          '',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          newsDetail?['full_text'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        if ((newsDetail?['origin_url'] ?? '')
                            .toString()
                            .isNotEmpty)
                          TextButton(
                            onPressed: () {
                              launchUrlString(newsDetail!['origin_url']);
                            },
                            child: const Text('원문 보기'),
                          ),
                        if ((newsDetail?['naver_url'] ?? '')
                            .toString()
                            .isNotEmpty)
                          TextButton(
                            onPressed: () {
                              launchUrlString(newsDetail!['naver_url']);
                            },
                            child: const Text('네이버 기사'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
