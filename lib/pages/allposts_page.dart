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
  5660: '강원특별자치도',
  6129: '충북특별자치도',
  6580: '충청남도',
  7376: '전라북도',
  8143: '전라남도',
  9073: '경상북도',
  10404: '경상남도',
  11977: '제주특별자치도',
};

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}


class _AllPostsPageState extends State<AllPostsPage> with TickerProviderStateMixin {
  List<dynamic> posts = [];
  List<bool> isLikedList = [];
  List<int> likeCountList = [];
  List<int> commentCountList = [];

  final storage = const FlutterSecureStorage();
  String? accessToken;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadTokenAndPosts();
  }

  Widget _buildBadge(int point) {
    String label = 'Bronze';
    Color color = Colors.brown;
    IconData icon = Icons.military_tech;
    if (point >= 5000) {
      label = 'Platinum';
      color = Colors.blueGrey;
      icon = Icons.workspace_premium;
    } else if (point >= 3000) {
      label = 'Gold';
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (point >= 1000) {
      label = 'Silver';
      color = Colors.grey;
      icon = Icons.military_tech;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadTokenAndPosts() async {
    accessToken = await storage.read(key: 'accessToken');
    await fetchPosts();
  }

  Future<void> fetchPosts({String? regionName}) async {
    String query = '?type=normal';
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
        likeCountList = posts.map<int>((post) => post['like_count'] ?? 0).toList();
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
      }
    } catch (e) {
      print('❌ 오류: $e');
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
      print('❌ 댓글 수 조회 오류: $e');
    }
    return 0;
  }

  Future<bool> fetchLikeStatus(int postId) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like/status');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['liked'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> toggleLike(int index) async {
    final postId = posts[index]['id'];
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like');
    final isLiked = isLikedList[index];

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
      }
    } catch (e) {
      print('❌ 좋아요 예외: $e');
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

  String? resolveImageUrl(dynamic urls) {
    if (urls is List && urls.isNotEmpty) {
      String url = urls.first;
      if (url.startsWith('/static')) return 'http://54.253.211.96:8000$url';
      if (url.startsWith('http')) return url;
    }
    if (urls is String && urls.isNotEmpty) {
      if (urls.startsWith('/static')) return 'http://54.253.211.96:8000$urls';
      if (urls.startsWith('http')) return urls;
    }
    return null;
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
          title: const Text('자유게시글', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.tune, color: Colors.black),
              onSelected: (selectedRegion) => fetchPosts(regionName: selectedRegion),
              itemBuilder: (context) => regionNames.values
                  .map((region) => PopupMenuItem(value: region, child: Text(region)))
                  .toList(),
            ),
          ],
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
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [Tab(text: '전체글'), Tab(text: '인기글')],
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final regionName = regionNames[post['region_id']] ?? '지역 정보 없음';
            final author = post['author'] ?? {};
            final profileImageUrl = resolveImageUrl(author['profile_imageURL']);
            final postImageUrl = resolveImageUrl(post['post_imageURLs']);
            final username = author['username'] ?? '알 수 없음';
            final point = author['point'] ?? 0;

            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/allpostdetail', arguments: post),
              child: PostCard(
                username: username,
                point: point,
                badgeLabel: getBadgeLabel(point),
                timeAgo: parseTimeAgo(post['created_at']),
                title: post['title'] ?? '',
                description: post['content'] ?? '',
                location: regionName,
                likes: likeCountList[index],
                comments: commentCountList[index],
                isLiked: isLikedList[index],
                imageUrl: postImageUrl,
                profileImageUrl: profileImageUrl,
                onLikePressed: () => toggleLike(index),
                badgeWidget: _buildBadge(point),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final int point;
  final String badgeLabel;
  final String timeAgo;
  final String title;
  final String description;
  final String location;
  final int likes;
  final int comments;
  final bool isLiked;
  final String? imageUrl;
  final String? profileImageUrl;
  final VoidCallback onLikePressed;
  final Widget badgeWidget;


  const PostCard({
    super.key,
    required this.username,
    required this.point,
    required this.badgeLabel,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.location,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.onLikePressed,
    required this.badgeWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
              CircleAvatar(
                radius: 16,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('lib/asset/sample_profile.jpg') as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(username,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 6),
                      badgeWidget,
                    ],
                  ),
                  Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(description, style: const TextStyle(fontSize: 13)),
          ),
          if (imageUrl != null)
            Column(
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onLikePressed,
                child: Row(
                  children: [
                    Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent, size: 20),
                    const SizedBox(width: 4),
                    Text('$likes',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment, size: 20, color: Colors.blueAccent),
              const SizedBox(width: 4),
              Text('$comments',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(location,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
