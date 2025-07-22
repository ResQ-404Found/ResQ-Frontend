import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'all_post_detail_page.dart';

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

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  List<dynamic> posts = [];
  List<bool> isLikedList = [];
  List<int> likeCountList = [];

  final storage = const FlutterSecureStorage();
  String? accessToken;

  @override
  void initState() {
    super.initState();
    loadTokenAndPosts();
  }

  Future<void> loadTokenAndPosts() async {
    accessToken = await storage.read(key: 'accessToken');
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('http://54.253.211.96:8000/api/posts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        posts = data;
        likeCountList = posts.map<int>((post) => post['like_count'] ?? 0).toList();
        isLikedList = List.filled(posts.length, false); // 초기화

        setState(() {}); // 임시 로딩 표시용

        // 각 게시글 좋아요 상태 확인
        for (int i = 0; i < posts.length; i++) {
          final postId = posts[i]['id'];
          final liked = await fetchLikeStatus(postId);
          setState(() {
            isLikedList[i] = liked;
          });
        }
      } else {
        print('게시글 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<bool> fetchLikeStatus(int postId) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like/status');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['liked'] ?? false;
      } else {
        print('좋아요 상태 확인 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('좋아요 상태 요청 중 오류 발생: $e');
      return false;
    }
  }

  Future<void> toggleLike(int index) async {
    final postId = posts[index]['id'];
    final isLiked = isLikedList[index];
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like');

    try {
      final response = isLiked
          ? await http.delete(url, headers: {'Authorization': 'Bearer $accessToken'})
          : await http.post(url, headers: {'Authorization': 'Bearer $accessToken'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLikedList[index] = !isLiked;
          likeCountList[index] = data['data']['like_count'] ?? likeCountList[index];
        });
      } else {
        print('좋아요 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('좋아요 중 오류 발생: $e');
    }
  }

  String parseTimeAgo(String time) {
    final dateTime = DateTime.parse(time).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}초 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    return '${diff.inDays}일 전';
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.black),
            onSelected: (String selectedRegion) {
              print('선택된 지역: $selectedRegion');
            },
            itemBuilder: (BuildContext context) => regionNames.values.map((region) {
              return PopupMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
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
      body: (posts.isEmpty || isLikedList.length != posts.length)
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final regionId = post['region_id'];
          final regionName = regionNames[regionId] ?? '지역 정보 없음';
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllPostDetailPage(post: post),
                ),
              );
            },
            child: PostCard(
              username: '${post['author']?['nickname'] ?? '알 수 없음'}',
              timeAgo: parseTimeAgo(post['created_at']),
              description: post['content'] ?? '',
              location: regionName,
              likes: likeCountList[index],
              comments: post['view_count'] ?? 0,
              isLiked: isLikedList[index],
              onLikePressed: () => toggleLike(index),
            ),
          );
        },
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
  final bool isLiked;
  final VoidCallback onLikePressed;

  const PostCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.description,
    required this.location,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.onLikePressed,
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
                            const Icon(Icons.location_pin, size: 16, color: Colors.red),
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
                    GestureDetector(
                      onTap: onLikePressed,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 25,
                        color: isLiked ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, size: 25),
                    const SizedBox(width: 4),
                    Text(
                      '$comments',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
