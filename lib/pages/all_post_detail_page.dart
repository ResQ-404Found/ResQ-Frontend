import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AllPostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const AllPostDetailPage({super.key, required this.post});

  @override
  State<AllPostDetailPage> createState() => _AllPostDetailPageState();
}

class _AllPostDetailPageState extends State<AllPostDetailPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> comments = [];
  int? replyingTo; // 대댓글 대상 comment_id
  final commentController = TextEditingController();
  int myUserId = -1;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchComments();
  }

  Future<void> fetchUserId() async {
    final token = await storage.read(key: 'accessToken');
    final res = await http.get(
      Uri.parse('http://54.253.211.96:8000/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() => myUserId = json['id']);
    }
  }

  Future<void> fetchComments() async {
    final res = await http.get(Uri.parse(
        'http://54.253.211.96:8000/api/comments?post_id=${widget.post['id']}'));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      setState(() {
        comments = decoded['data'];
      });
    }
  }

  Future<void> toggleLike(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final res = await http.post(
      Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/like'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 400) {
      await http.delete(
        Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/like'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    fetchComments();
  }

  Future<void> writeComment(String text) async {
    final token = await storage.read(key: 'accessToken');
    final res = await http.post(
      Uri.parse('http://54.253.211.96:8000/api/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'post_id': widget.post['id'],
        'content': text,
        if (replyingTo != null) 'parent_comment_id': replyingTo
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      commentController.clear();
      replyingTo = null;
      fetchComments();
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    await http.delete(
      Uri.parse('http://54.253.211.96:8000/api/comments/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchComments();
  }

  Future<void> editComment(int commentId, String newText) async {
    final token = await storage.read(key: 'accessToken');
    await http.patch(
      Uri.parse('http://54.253.211.96:8000/api/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'content': newText}),
    );
    fetchComments();
  }

  Widget commentTile(Map<String, dynamic> comment, {bool isReply = false}) {
    final isMine = comment['user_id'] == myUserId;
    final replies = comment['replies'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding:
          EdgeInsets.only(left: isReply ? 40 : 0, right: 10, top: 5),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment['author']?['username'] ?? '알 수 없음',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(comment['created_at']?.split('T')[0] ?? ''),
            ],
          ),
          subtitle: Text(comment['content'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => toggleLike(comment['id']),
                child: const Icon(Icons.favorite_border, size: 20),
              ),
              const SizedBox(width: 4),
              Text('${comment['like_count'] ?? 0}'),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => replyingTo = comment['id']),
                child: const Icon(Icons.reply, size: 20),
              ),
              if (isMine)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController()
                            ..text = comment['content'] ?? '';
                          return AlertDialog(
                            title: const Text('댓글 수정'),
                            content: TextField(controller: controller),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  editComment(comment['id'], controller.text);
                                },
                                child: const Text('수정'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      deleteComment(comment['id']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ],
                ),
            ],
          ),
        ),
        for (var reply in replies) commentTile(reply, isReply: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('게시글 상세')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      post['author']?['profile_imageURL'] ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(
                    post['author']?['username'] ?? '작성자',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                  Text(post['created_at']?.split('T')[0] ?? '날짜 없음'),
                ),
                const SizedBox(height: 12),
                Text(post['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(post['content'] ?? ''),
                const SizedBox(height: 10),
                if ((post['post_imageURLs'] as List?)?.isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post['post_imageURLs'][0]),
                  ),
                const SizedBox(height: 20),
                const Text('댓글', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (var c in comments)
                  if (c['parent_comment_id'] == null) commentTile(c),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? '댓글을 입력하세요'
                          : '답글을 입력하세요',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () =>
                      writeComment(commentController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
