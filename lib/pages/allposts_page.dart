import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '전체글',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Divider(
            height: 1,
            thickness: 3.0,
            indent: 200,
            endIndent: 200,
            color: Colors.black54,
          ),
        ),
      ),

      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text('상세 페이지'),
                          backgroundColor: Colors.white,
                          iconTheme: const IconThemeData(color: Colors.black87),
                          titleTextStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.chevron_left, size: 35),
                            onPressed: () => Navigator.pop(context),
                          ),
                          elevation: 0,
                        ),
                        body: const Center(child: Text('상세 페이지 구현 예정')),
                      ),
                ),
              );
            },
            child: PostCard(
              username: '작성자 ${post['user_id']}',
              timeAgo: post['created_at'] ?? '',
              description: post['content'] ?? '',
              location: '지역 ${post['region_id']}',
              likes: post['like_count'] ?? 0,
              comments: post['view_count'] ?? 0,
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색
              blurRadius: 10, // 퍼짐 정도
              offset: Offset(0, -2), // 위쪽으로 살짝 그림자
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Container에서 색 처리했으므로 투명
          elevation: 0, // 내부 elevation 제거
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
          selectedItemColor: Colors.redAccent, // 선택된 아이콘 색
          unselectedItemColor: Colors.grey[300], // 비선택 아이콘 색
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 30),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)),
              label: '재난메뉴',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String description;
  final String location;
  final int likes;
  final int comments;

  const PostCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.description,
    required this.location,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 12.0),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 유저명 + 시간 + 위치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.location_pin,
                              size: 16,
                              color: Colors.red,
                            ),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.more_vert, color: Colors.black54),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: Icon(Icons.image, size: 300, color: Colors.grey[400]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 25),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, size: 25),
                    const SizedBox(width: 4),
                    Text(
                      '$comments',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
