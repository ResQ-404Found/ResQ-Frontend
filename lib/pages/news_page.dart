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
  List<Map<String, dynamic>> youtubeVideos = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  final int maxPages = 2;
  bool showSummary = false;
  String aiSummary = '';
  bool isSummaryLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDisasterNews();
    fetchYoutubeVideos();
  }
  Future<void> fetchAISummary() async {
    setState(() {
      isSummaryLoading = true;
    });

    final url = Uri.parse('http://54.253.211.96:8000/api/news/ai');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        aiSummary = data['summary'];
        showSummary = true;
      });
    } else {
      setState(() {
        aiSummary = '요약을 불러오는 데 실패했습니다.';
        showSummary = true;
      });
    }

    setState(() {
      isSummaryLoading = false;
    });
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
        newsList = paginatedItems.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'title': item['title'] ?? '제목 없음',
            'date': item['pub_date']?.toString().replaceAll('T', ' ') ?? '날짜 없음',
            'origin_url': item['origin_url'], // ✅ 추가됨
          };
        }).toList();
      });
    } else {
      print('뉴스 API 호출 실패: ${response.statusCode}');
    }
  }

  Future<void> fetchYoutubeVideos() async {
    final url = Uri.parse('http://54.253.211.96:8000/api/youtube?query=재난&channel=KBS News');

    final response = await http.get(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        youtubeVideos = items.map<Map<String, dynamic>>((item) {
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
        title: const Text('재난 뉴스', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: newsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // ⬇ AI 요약 버튼 및 요약 박스
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (showSummary) {
                        setState(() {
                          showSummary = false;
                        });
                      } else {
                        fetchAISummary();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('AI 요약 보기'),
                  ),
                ],
              ),
            ),
            if (showSummary)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: isSummaryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                    aiSummary,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            // ⬇ 유튜브 리스트
            SizedBox(
              height: 120,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
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

            // ⬇ 뉴스 카드 리스트
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return InkWell(
                  onTap: () {
                    final url = news['origin_url'];
                    if (url != null && url is String) {
                      launchUrlString(url);
                    }
                  },
                  child: Card(
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: TextStyle(color: Colors.grey[700]),
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

            // ⬇ 페이지 네비게이션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 0 ? () => goToPage(currentPage - 1) : null,
                ),
                Text('${currentPage + 1} / $maxPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < maxPages - 1 ? () => goToPage(currentPage + 1) : null,
                ),
              ],
            ),
          ],
        ),
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
