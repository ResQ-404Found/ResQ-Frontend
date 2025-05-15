import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;

String decodeHtmlEntities(String htmlString) {
  final document = html_parser.parse(htmlString);
  final String parsedString = document.body?.text ?? htmlString;
  return parsedString;
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, String>> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchDisasterNews();
  }

  Future<void> fetchDisasterNews() async {
    final url = Uri.parse(
      'https://openapi.naver.com/v1/search/news.json?query=재난&display=20&sort=date',
    );

    final response = await http.get(
      url,
      headers: {
        'X-Naver-Client-Id': 'Px2OOf0dQFJLmbrozUdW',
        'X-Naver-Client-Secret': 'ik8BtDwvl0',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = jsonData['items'];

      setState(() {
        newsList =
            items.map<Map<String, String>>((item) {
              return {
                'title': decodeHtmlEntities(item['title'] ?? '제목 없음'),
                'date': item['pubDate'] ?? '날짜 없음',
              };
            }).toList();
      });
    } else {
      print('API 호출 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('재난 뉴스'), backgroundColor: Colors.white),
      body:
          newsList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final news = newsList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //사진 자리
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  news['title']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  news['date']!,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
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
