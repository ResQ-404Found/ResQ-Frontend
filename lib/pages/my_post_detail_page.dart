import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key});

  Future<void> _deletePost(BuildContext context, int postId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${response.body}')),
      );
    }
  }

  void _showPostOptions(BuildContext context, int postId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정하기'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/postEdit', arguments: postId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제하기'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('게시글 삭제'),
                  content: const Text('정말 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deletePost(context, postId);
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      return const Scaffold(
        body: Center(child: Text('잘못된 접근입니다')),
      );
    }
    final Map<String, dynamic> post = args;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${post['region_id'] ?? '재난'} 커뮤니티'),

        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showPostOptions(context, post['id']),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    post['author']?['profile_imageURL'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  post['author']?['username'] ?? '익명',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  post['created_at']?.substring(0, 10) ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (post['post_imageURLs'] != null && post['post_imageURLs'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(post['post_imageURLs'][0]),
              ),
            const SizedBox(height: 20),
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 20),
                const SizedBox(width: 5),
                Text('${post['like_count'] ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.remove_red_eye, size: 20),
                const SizedBox(width: 5),
                Text('${post['view_count'] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
