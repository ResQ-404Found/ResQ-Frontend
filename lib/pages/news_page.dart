import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher_string.dart';
import 'news_detail_page.dart';

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
  List<Map<String, dynamic>> youtubeVideos = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  final int maxPages = 2;

  @override
  void initState() {
    super.initState();
    fetchDisasterNews();
    fetchYoutubeVideos();
  }

  Future<void> fetchDisasterNews() async {
    final int start = currentPage * itemsPerPage;
    final query = '재난';

    final url = Uri.parse('http://54.253.211.96:8000/api/news/?query=$query');

    final response = await http.get(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(utf8.decode(response.bodyBytes));
      final paginatedItems = items.skip(start).take(itemsPerPage).toList();

      setState(() {
        newsList =
            paginatedItems.map<Map<String, dynamic>>((item) {
              return {
                'id': item['id'],
                'title': item['title'] ?? '제목 없음',
                'date':
                    item['pub_date']?.toString().replaceAll('T', ' ') ??
                    '날짜 없음',
              };
            }).toList();
      });
    } else {
      print('뉴스 API 호출 실패: ${response.statusCode}');
    }
  }

  Future<void> fetchYoutubeVideos() async {
    final url = Uri.parse('http://54.253.211.96:8000/api/youtube?query=재난');

    final response = await http.get(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        youtubeVideos =
            items.map<Map<String, dynamic>>((item) {
              return {
                'title': item['title'],
                'thumbnail': item['thumbnail_url'],
                'videoUrl': item['video_url'],
                'channel': item['channel_title'],
              };
            }).toList();
      });
    } else {
      print('유튜브 API 호출 실패: ${response.statusCode}');
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
                  const Padding(
                    padding: EdgeInsets.only(top: 16, left: 16),
                    child: Align(alignment: Alignment.centerLeft),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: youtubeVideos.length,
                      itemBuilder: (context, index) {
                        final video = youtubeVideos[index];
                        return GestureDetector(
                          onTap: () => launchUrlString(video['videoUrl']),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(6),
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(video['thumbnail']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                video['channel'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        NewsDetailPage(newsId: news['id']),
                              ),
                            );
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
                onPressed: () => Navigator.pushNamed(context, '/map'),
              ),
              IconButton(
                icon: Icon(Icons.chat, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/allposts'),
              ),
              IconButton(
                icon: Icon(Icons.groups, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/community'),
              ),
              IconButton(
                icon: Icon(Icons.emergency_share),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
