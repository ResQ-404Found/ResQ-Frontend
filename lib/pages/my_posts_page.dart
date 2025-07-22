import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'all_post_detail_page.dart';
import 'edit_post_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    final response = await http.get(
      Uri.parse('http://54.253.211.96:8000/api/posts/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        posts = data;
        isLoading = false;
      });
    } else {
      print('게시글 요청 실패: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Future<void> deletePost(int postId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    final response = await http.delete(
      Uri.parse('http://54.253.211.96:8000/api/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
      fetchMyPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${response.statusCode}')),
      );
    }
  }

  String formatTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 작성한 글', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('작성한 글이 없습니다.'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final content = post['content'] ?? '';
          final createdAt = post['created_at'] ?? '';
          final images = post['post_imageURLs'] ?? [];
          final author = post['author'] ?? {};
          final profile = author['profile_imageURL'] ?? '';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllPostDetailPage(post: post),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                profile.isNotEmpty ? profile : 'https://via.placeholder.com/150',
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(author['username'] ?? '작성자',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formatTime(createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            subtitle: Row(
              children: [
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[0],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (images.isNotEmpty) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    content,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPostPage(post: post),
                    ),
                  ).then((_) => fetchMyPosts());
                } else if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('게시글 삭제'),
                      content: const Text('정말 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deletePost(post['id']);
                          },
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
          );
        },
      ),
    );
  }
}
