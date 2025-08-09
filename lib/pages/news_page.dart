import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> newsList = [];
  List<Map<String, dynamic>> youtubeVideos = [];

  int currentPage = 0;
  final int itemsPerPage = 10;
  int get totalPages {
    if (_allNews.isEmpty) return 1;
    return ((_allNews.length + itemsPerPage - 1) ~/ itemsPerPage).clamp(
      1,
      1000,
    );
  }

  bool showSummary = false;
  String aiSummary = '';
  bool isSummaryLoading = false;

  bool _isNewsLoading = true;
  bool _isYoutubeLoading = true;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentYoutubePage = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    await Future.wait([
      fetchAllNewsOnceSafe(), 
      fetchYoutubeVideos(limit: 5),
    ]);
    _applyPage(0);
  }

  String _cleanedSummary(String summary) {
    final hotKeywordIndex = summary.indexOf('HOT 키워드:');
    return hotKeywordIndex == -1
        ? summary
        : summary.substring(0, hotKeywordIndex).trim();
  }

  List<String> _extractKeywords(String summary) {
    final hotKeywordIndex = summary.indexOf('HOT 키워드:');
    if (hotKeywordIndex == -1) return [];
    final keywordString = summary.substring(
      hotKeywordIndex + 'HOT 키워드:'.length,
    );
    return keywordString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> fetchAISummary() async {
    setState(() {
      showSummary = true;
      isSummaryLoading = true;
      aiSummary = '';
    });

    try {
      final url = Uri.parse('http://54.253.211.96:8000/api/news/ai');
      final response = await http
          .post(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          aiSummary = data['summary'] ?? '';
        });
      } else {
        setState(() {
          aiSummary = '요약을 불러오는 데 실패했습니다.';
        });
      }
    } catch (_) {
      setState(() {
        aiSummary = '요약 요청 중 오류가 발생했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSummaryLoading = false;
        });
      }
    }
  }

  Future<void> fetchAllNewsOnceSafe() async {
    setState(() => _isNewsLoading = true);

    try {
      final url1 = Uri.http('54.253.211.96:8000', '/api/news/', {
        'query': '재난',
      });

      final res1 = await http
          .get(url1, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      List<dynamic> items = [];
      if (res1.statusCode == 200) {
        items = json.decode(utf8.decode(res1.bodyBytes));
      }

      if (items.isEmpty) {
        final fallbackUrl = Uri.parse(
          'http://54.253.211.96:8000/api/news/?query=${Uri.encodeComponent('재난')}',
        );
        final res2 = await http
            .get(fallbackUrl, headers: {'accept': 'application/json'})
            .timeout(const Duration(seconds: 12));
        if (res2.statusCode == 200) {
          items = json.decode(utf8.decode(res2.bodyBytes));
        }
      }

      setState(() {
        _allNews =
            items.map<Map<String, dynamic>>((item) {
              return {
                'id': item['id'],
                'title': item['title'] ?? '제목 없음',
                'date': (item['pub_date']?.toString() ?? '').replaceAll(
                  'T',
                  ' ',
                ),
                'origin_url': item['origin_url'],
              };
            }).toList();
      });
    } catch (e) {
      debugPrint('뉴스 API 예외: $e');
      setState(() {
        _allNews = [];
      });
    } finally {
      if (mounted) setState(() => _isNewsLoading = false);
    }
  }

  Future<void> fetchYoutubeVideos({int limit = 5}) async {
    setState(() {
      _isYoutubeLoading = true;
    });

    try {
      final url = Uri.http('54.253.211.96:8000', '/api/youtube', {
        'query': '재난',
        'channel': 'KBS News',
        'limit': '$limit',
      });

      final response = await http
          .get(url, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(
          utf8.decode(response.bodyBytes),
        );
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
        debugPrint('유튜브 API 실패: ${response.statusCode}');
        youtubeVideos = [];
      }
    } catch (e) {
      debugPrint('유튜브 API 예외: $e');
      youtubeVideos = [];
    } finally {
      if (mounted) {
        setState(() {
          _isYoutubeLoading = false;
        });
      }
    }
  }

  void _applyPage(int page) {
    final int clampedPage = page.clamp(0, totalPages - 1);
    final int start = clampedPage * itemsPerPage;

    if (start >= _allNews.length) {
      setState(() {
        currentPage = clampedPage;
        newsList = [];
      });
      return;
    }

    final int end = (start + itemsPerPage).clamp(0, _allNews.length);
    setState(() {
      currentPage = clampedPage;
      newsList = _allNews.sublist(start, end);
    });
  }

  void goToPage(int page) => _applyPage(page);

  @override
  Widget build(BuildContext context) {
    final bool isInitialLoading = _isNewsLoading && newsList.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '재난 뉴스',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed:
                              isSummaryLoading
                                  ? null // 로딩 동안 비활성화
                                  : () {
                                    if (showSummary) {
                                      setState(() => showSummary = false);
                                    } else {
                                      fetchAISummary();
                                    }
                                  },
                          icon: const Icon(Icons.smart_toy),
                          label: Text(
                            isSummaryLoading ? '요약 불러오는 중…' : 'AI 요약 보기',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (showSummary)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: _buildSummaryCard(),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '재난 관련 영상',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child:
                          _isYoutubeLoading || youtubeVideos.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : PageView.builder(
                                controller: _pageController,
                                itemCount: youtubeVideos.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentYoutubePage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final video = youtubeVideos[index];
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            launchUrlString(video['videoUrl']),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              video['thumbnail'],
                                              width: 320,
                                              height: 175,
                                              fit: BoxFit.cover,
                                              cacheWidth: 640,
                                              cacheHeight: 350,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            video['channel'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),
                  if (youtubeVideos.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: youtubeVideos.length,
                            effect: WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.black,
                              dotColor: Colors.grey[300]!,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  if (newsList.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            _isNewsLoading ? '' : '표시할 뉴스가 없습니다.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverList.builder(
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          final news = newsList[index];
                          return _buildNewsTile(news);
                        },
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                              currentPage > 0
                                  ? () => goToPage(currentPage - 1)
                                  : null,
                        ),
                        Text(
                          '${currentPage + 1} / $totalPages',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              (currentPage < totalPages - 1)
                                  ? () => goToPage(currentPage + 1)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child:
          isSummaryLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanedSummary(aiSummary),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _extractKeywords(aiSummary).map((keyword) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              keyword,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildNewsTile(Map<String, dynamic> news) {
    return InkWell(
      onTap: () {
        final url = news['origin_url'];
        if (url != null && url is String && url.isNotEmpty) {
          launchUrlString(url);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news['title'] ?? '제목 없음',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              news['date'] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/map');
            break;
          case 1:
            Navigator.pushNamed(context, '/chatbot');
            break;
          case 2:
            Navigator.pushNamed(context, '/community');
            break;
          case 3:
            Navigator.pushNamed(context, '/disastermenu');
            break;
          case 4:
            Navigator.pushNamed(context, '/user');
            break;
        }
      },
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedIconTheme: const IconThemeData(size: 30),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.place), label: '지도'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '재난메뉴'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '마이'),
      ],
    );
  }
}
