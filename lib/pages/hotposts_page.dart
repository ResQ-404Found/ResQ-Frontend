import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class HotPostsPage extends StatefulWidget {
  const HotPostsPage({super.key});

  @override
  State<HotPostsPage> createState() => _HotPostsPageState();
}

class _HotPostsPageState extends State<HotPostsPage>
    with TickerProviderStateMixin {
  List<dynamic> posts = [];
  List<bool> isLikedList = [];
  List<int> likeCountList = [];
  List<int> commentCountList = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? accessToken;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadTokenAndPosts();
  }

  Future<void> loadTokenAndPosts() async {
    accessToken = await storage.read(key: 'accessToken');
    await fetchPosts();
  }

  Future<void> fetchPosts({String? regionName}) async {
    String query = '?type=disaster';
    if (selectedTabIndex == 1) {
      query += '&sort=like_count';
    }
    if (regionName != null) {
      query += '&region=${Uri.encodeComponent(regionName)}';
    }

    final url = Uri.parse('http://54.253.211.96:8000/api/posts$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        posts = data;
        likeCountList =
            posts.map<int>((post) => post['like_count'] ?? 0).toList();
        isLikedList = List.filled(posts.length, false);
        commentCountList = List.filled(posts.length, 0);
        setState(() {});

        for (int i = 0; i < posts.length; i++) {
          final liked = await fetchLikeStatus(posts[i]['id']);
          final commentCount = await fetchCommentCount(posts[i]['id']);
          if (mounted) {
            setState(() {
              isLikedList[i] = liked;
              commentCountList[i] = commentCount;
            });
          }
        }
      } else {
        print('게시글 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<int> fetchCommentCount(int postId) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$postId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).length;
      }
    } catch (e) {
      print('댓글 수 조회 오류: $e');
    }
    return 0;
  }

  Future<bool> fetchLikeStatus(int postId) async {
    final url = Uri.parse(
      'http://54.253.211.96:8000/api/posts/$postId/like/status',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['liked'] ?? false;
      }
    } catch (e) {
      print('좋아요 상태 오류: $e');
    }
    return false;
  }

  Future<void> toggleLike(int index) async {
    final postId = posts[index]['id'];
    final isLiked = isLikedList[index];
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like');
    try {
      final response =
          isLiked
              ? await http.delete(
                url,
                headers: {'Authorization': 'Bearer $accessToken'},
              )
              : await http.post(
                url,
                headers: {'Authorization': 'Bearer $accessToken'},
              );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLikedList[index] = !isLiked;
          likeCountList[index] =
              data['data']['like_count'] ?? likeCountList[index];
        });
      }
    } catch (e) {
      print('좋아요 토글 오류: $e');
    }
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

  String getBadgeLabel(int point) {
    if (point >= 5000) return 'Platinum';
    if (point >= 3000) return 'Gold';
    if (point >= 1000) return 'Silver';
    return 'Bronze';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: selectedTabIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('재난게시글', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                selectedTabIndex = index;
              });
              fetchPosts();
            },
            indicatorColor: Colors.black,
            indicatorWeight: 2.5,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: const [Tab(text: '전체글'), Tab(text: '인기글')],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.tune, color: Colors.black),
              onSelected:
                  (selectedRegion) => fetchPosts(regionName: selectedRegion),
              itemBuilder:
                  (context) =>
                      regionNames.values
                          .map(
                            (region) => PopupMenuItem(
                              value: region,
                              child: Text(region),
                            ),
                          )
                          .toList(),
            ),
          ],
        ),
        body:
            (posts.isEmpty || isLikedList.length != posts.length)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final imageUrl = resolveImageUrl(post['post_imageURLs']);
                    final author = post['author'] ?? {};
                    final username = author['username'] ?? '알 수 없음';
                    final point = author['point'] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/allpostdetail',
                          arguments: post,
                        );
                      },
                      child: PostCard(
                        username: username,
                        point: point,
                        timeAgo: parseTimeAgo(post['created_at']),
                        description: post['content'] ?? '',
                        location: regionNames[post['region_id']] ?? '지역 정보 없음',
                        likes: likeCountList[index],
                        comments: commentCountList[index],
                        isLiked: isLikedList[index],
                        imageUrl: imageUrl,
                        onLikePressed: () => toggleLike(index),
                        badgeLabel: getBadgeLabel(point),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username, timeAgo, description, location, badgeLabel;
  final int likes, comments, point;
  final bool isLiked;
  final String? imageUrl;
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
    required this.imageUrl,
    required this.onLikePressed,
    required this.point,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.redAccent, width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFECE2F0),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onLikePressed,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment, size: 20, color: Colors.blueAccent),
              const SizedBox(width: 4),
              Text(
                '$comments',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
