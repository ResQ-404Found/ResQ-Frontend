import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityMainPage extends StatefulWidget {
  const CommunityMainPage({super.key});

  @override
  CommunityMainPageState createState() => CommunityMainPageState();
}

const Map<int, String> regionNames = {
  1: '서울특별시',
  2559: '부산광역시',
  2784: '대구광역시',
  3011: '인천광역시',
  3235: '광주광역시',
  3481: '대전광역시',
  3664: '울산광역시',
  3759: '세종특별자치시',
  3793: '경기도',
  5660: '강원도',
  6129: '충청북도',
  6580: '충청남도',
  7376: '전라북도',
  8143: '전라남도',
  9073: '경상북도',
  10404: '경상남도',
  11977: '제주도',
};

class CommunityMainPageState extends State<CommunityMainPage> {
  List<dynamic> posts = [];
  List<dynamic> popularPosts = [];
  List<dynamic> searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool searchPerformed = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    fetchPopularPosts();
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('http://54.253.211.96:8000/api/posts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts = data;
        });
      } else {
        print('게시글 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<void> fetchPopularPosts() async {
    final url = Uri.parse(
      'http://54.253.211.96:8000/api/posts?sort=like_count',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          popularPosts = data;
        });
      } else {
        print('인기글 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('인기글 오류 발생: $e');
    }
  }

  Future<void> searchPosts(String term) async {
    if (term.trim().isEmpty) return;

    setState(() {
      searchResults.clear();
      isSearching = true;
      searchPerformed = false;
    });

    final url = Uri.parse('http://54.253.211.96:8000/api/posts?term=$term');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          searchResults = data;
          searchPerformed = true;
        });
      } else {
        print('검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('검색 중 오류 발생: $e');
    }
  }

  void cancelSearch() {
    setState(() {
      isSearching = false;
      searchPerformed = false;
      _searchController.clear();
      searchResults.clear();
    });
  }

  String? resolveImageUrl(dynamic urls) {
    if (urls is List && urls.isNotEmpty) {
      final url = urls.first;
      if (url.startsWith('/static')) {
        return 'http://54.253.211.96:8000$url';
      } else if (url.startsWith('http')) {
        return url;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          color: Colors.white,
          child: Row(
            children: [
              if (isSearching)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: cancelSearch,
                ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: searchPosts,
                  decoration: InputDecoration(
                    hintText: '검색하기',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => searchPosts(_searchController.text),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          isSearching
              ? Padding(
                padding: const EdgeInsets.all(16),
                child:
                    searchResults.isNotEmpty
                        ? ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final post = searchResults[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "작성자: ${post['author']?['username'] ?? post['user_id'] ?? '알 수 없음'}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                        : const Center(child: Text('검색결과가 없습니다')),
              )
              : buildDefaultContent(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/map');
              break;
            case 1:
              Navigator.pushNamed(context, '/chatbot');
              break;
            case 2:
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
        unselectedItemColor: Colors.grey[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 30),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.place), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '재난메뉴'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: '마이',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createpost'),
        backgroundColor: Colors.redAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 35),
          sectionHeader('인기글', '/hotposts'),
          const SizedBox(height: 10),
          buildHorizontalPostList(popularPosts),
          const SizedBox(height: 35),
          sectionHeader('전체글', '/allposts'),
          const SizedBox(height: 10),
          buildHorizontalPostList(posts),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            child: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalPostList(List<dynamic> postsList) {
    if (postsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('게시글이 없습니다'),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: postsList.length,
        itemBuilder: (context, index) {
          final post = postsList[index];
          final regionId = int.tryParse('${post['region_id']}');
          final imageUrl = resolveImageUrl(post['post_imageURLs']);

          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        imageUrl != null
                            ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                            )
                            : Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 48),
                            ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        regionNames[regionId] ?? '알 수 없음',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        post['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '작성자 ${post['author']?['username'] ?? post['user_id'] ?? '알 수 없음'}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
