import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher_string.dart';

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
  List<Map<String, dynamic>> newsList = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  final int maxPages = 25; // 페이지 수 

  @override
  void initState() {
    super.initState();
    fetchDisasterNews();
  }

  Future<void> fetchDisasterNews() async {
    int start = currentPage * itemsPerPage + 1;

    final url = Uri.parse(
      'https://openapi.naver.com/v1/search/news.json?query=재난&display=$itemsPerPage&start=$start&sort=date',
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
            items.map<Map<String, dynamic>>((item) {
              return {
                'title': decodeHtmlEntities(item['title'] ?? '제목 없음'),
                'date': item['pubDate'] ?? '날짜 없음',
                'link': item['link'] ?? '',
              };
            }).toList();
      });
    } else {
      print('API 호출 실패: ${response.statusCode}');
    }
  }

  void goToPage(int page) {
    setState(() {
      currentPage = page;
      newsList = [];
    });
    fetchDisasterNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('재난 뉴스'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          newsList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return InkWell(
                          onTap: () {
                            if (news['link'] != null &&
                                news['link'].toString().isNotEmpty) {
                              launchUrlString(news['link']);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          news['title'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          news['date'],
                                          style: TextStyle(
                                            color: Colors.grey[700],
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
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed:
                            currentPage > 0
                                ? () => goToPage(currentPage - 1)
                                : null,
                      ),
                      Text('${currentPage + 1} / $maxPages'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed:
                            currentPage < maxPages - 1
                                ? () => goToPage(currentPage + 1)
                                : null,
                      ),
                    ],
                  ),
                ],
              ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.feed, color: Colors.grey[800]),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.groups, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.emergency_share, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
