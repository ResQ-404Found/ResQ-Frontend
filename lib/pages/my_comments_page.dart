import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'all_post_detail_page.dart';

class MyCommentsPage extends StatefulWidget {
  const MyCommentsPage({super.key});

  @override
  State<MyCommentsPage> createState() => _MyCommentsPageState();
}

class _MyCommentsPageState extends State<MyCommentsPage> {
  List<dynamic> comments = [];
  Map<int, dynamic> postInfoCache = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyComments();
  }

  Future<void> fetchMyComments() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    final response = await http.get(
      Uri.parse('http://54.253.211.96:8000/api/comments/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        comments = data;
        isLoading = false;
      });

      for (var comment in data) {
        final postId = comment['post_id'];
        if (postId != null && !postInfoCache.containsKey(postId)) {
          fetchPostById(postId);
        }
      }
    } else {
      print('댓글 요청 실패: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPostById(int postId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    final response = await http.get(
      Uri.parse('http://54.253.211.96:8000/api/posts/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        postInfoCache[postId] = data;
      });
    } else {
      print('게시글 정보 요청 실패: ${response.statusCode}');
    }
  }

  String formatTime(String isoString) {
    final time = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return DateFormat('yyyy-MM-dd').format(time);
  }

  void _showEditDialog(int commentId, String currentContent) {
    final controller = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,

            title: const Text('댓글 수정'),
            content: TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(hintText: '수정할 댓글 내용을 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () async {
                  final newContent = controller.text.trim();
                  if (newContent.isEmpty) return;

                  final storage = FlutterSecureStorage();
                  final token = await storage.read(key: 'accessToken');

                  final response = await http.patch(
                    Uri.parse(
                      'http://54.253.211.96:8000/api/comments/$commentId',
                    ),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({'content': newContent}),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    fetchMyComments();
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('댓글 수정 실패')));
                  }
                },
                child: const Text('저장', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  void _deleteComment(int commentId) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('댓글 삭제'),
            content: const Text('정말 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    final response = await http.patch(
      Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      fetchMyComments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글 삭제 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '내가 작성한 댓글',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0.0,
        scrolledUnderElevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : comments.isEmpty
              ? const Center(child: Text('작성한 댓글이 없습니다.'))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final postId = comment['post_id'];
                  final post = postInfoCache[postId];
                  final title =
                      (post != null && post['title'] != null)
                          ? post['title']
                          : '(제목 없음)';

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 10,
                    ),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목, 시간, 메뉴 한 줄로
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatTime(comment['created_at']),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDialog(
                                      comment['id'],
                                      comment['content'],
                                    );
                                  } else if (value == 'delete') {
                                    _deleteComment(comment['id']);
                                  }
                                },
                                itemBuilder:
                                    (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('수정'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('삭제'),
                                      ),
                                    ],
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 댓글 내용
                          Text(
                            comment['content'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),

                          const SizedBox(height: 16),

                          // 좋아요/댓글/원문 보기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite_border,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post?['like_count'] ?? 0}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.mode_comment_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post?['comment_count'] ?? 0}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  if (post != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '/allpostdetail',
                                      arguments: post,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("게시글 정보를 불러올 수 없습니다."),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  '원문 보기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
