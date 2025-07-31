import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityMainPage extends StatefulWidget {
  const CommunityMainPage({super.key});

  @override
  State<CommunityMainPage> createState() => _CommunityMainPageState();
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

class _CommunityMainPageState extends State<CommunityMainPage> {
  List<dynamic> posts = [];
  List<dynamic> popularPosts = [];
  final _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchDisasterPosts();
    fetchNormalPosts();
  }

  Future<void> fetchDisasterPosts() async {
    final response = await http.get(Uri.parse('http://54.253.211.96:8000/api/posts?type=disaster'));
    if (response.statusCode == 200) {
      setState(() {
        popularPosts = jsonDecode(response.body);
      });
    }
  }

  Future<void> fetchNormalPosts() async {
    final response = await http.get(Uri.parse('http://54.253.211.96:8000/api/posts?type=normal'));
    if (response.statusCode == 200) {
      setState(() {
        posts = jsonDecode(response.body);
      });
    }
  }

  Future<void> searchPosts(String term) async {
    if (term.trim().isEmpty) return;
    setState(() {
      isSearching = true;
    });
    final response = await http.get(Uri.parse('http://54.253.211.96:8000/api/posts?term=$term'));
    if (response.statusCode == 200) {
      setState(() {
        searchResults = jsonDecode(response.body);
      });
    }
  }

  void cancelSearch() {
    setState(() {
      isSearching = false;
      searchResults.clear();
      _searchController.clear();
    });
  }

  String? resolveImageUrl(dynamic urls) {
    if (urls is String && urls.isNotEmpty) {
      if (urls.startsWith('/static')) {
        return 'http://54.253.211.96:8000$urls';
      } else if (urls.startsWith('http')) {
        return urls;
      }
    }

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

  Widget sectionHeader(String title, String route, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          child: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        )
      ],
    );
  }

  Widget buildPostList(List<dynamic> list) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final post = list[index];
          final region = regionNames[int.tryParse('${post['region_id']}')] ?? '알 수 없음';
          final author = post['author'] ?? {};
          final profileImageUrl = resolveImageUrl(author['profile_imageURL']);
          final postImageUrl = resolveImageUrl(post['post_imageURLs']);
          final username = author['username'] ?? '익명';
          final point = author['point'] ?? 0;
          final badgeLabel = getBadgeLabel(point);
          final likeCount = post['like_count'] ?? 0;
          final commentCount = post['comment_count'] ?? 0;
          final time = post['created_at'] ?? '';
          final title = post['title'] ?? '';

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(region,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(parseTimeAgo(time),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: postImageUrl != null
                      ? Image.network(
                    postImageUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  )
                      : Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('lib/asset/sample_profile.jpg') as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 6),
                    Text('by $username',
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.favorite_border, size: 16),
                    const SizedBox(width: 4),
                    Text('$likeCount', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.chat_bubble_outline, size: 16),
                    const SizedBox(width: 4),
                    Text('$commentCount', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          onSubmitted: searchPosts,
          decoration: InputDecoration(
            hintText: '검색하기',
            prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSearching
            ? ListView(
          children: searchResults
              .map((post) => ListTile(
            title: Text(post['title'] ?? ''),
            subtitle: Text(
              regionNames[int.tryParse('${post['region_id']}')] ?? '',
            ),
          ))
              .toList(),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader('재난게시글', '/hotposts', Icons.local_fire_department),
              const SizedBox(height: 10),
              buildPostList(popularPosts),
              const SizedBox(height: 30),
              sectionHeader('자유게시글 ', '/allposts', Icons.list_alt),
              const SizedBox(height: 10),
              buildPostList(posts),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createpost'),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 2, // 커뮤니티 탭 활성화
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
