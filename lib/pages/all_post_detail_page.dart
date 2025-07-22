// 게시글 상세 페이지 + 댓글 목록/작성/수정/삭제 + 좋아요 토글 + 게시글 수정/삭제 기능 포함 전체 코드
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AllPostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const AllPostDetailPage({super.key, required this.post});

  @override
  State<AllPostDetailPage> createState() => _AllPostDetailPageState();
}

class _AllPostDetailPageState extends State<AllPostDetailPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController editPostContentController = TextEditingController();
  List<dynamic> comments = [];
  bool isLoading = true;
  int? myUserId;
  bool isPostLiked = false;
  Map<int, bool> commentLikeStatus = {};

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchComments();
    fetchPostLikeStatus();
  }

  Future<void> fetchUserId() async {
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://54.253.211.96:8000/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          myUserId = data['data']['id'];
        });
      }
    }
  }

  Future<void> fetchComments() async {
    final postId = widget.post['id'];
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$postId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments = data;
          isLoading = false;
        });
        fetchAllCommentLikeStatus();
      }
    } catch (e) {
      print('댓글 API 오류: $e');
    }
  }

  Future<void> submitComment(String content) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post['id'],
        'content': content,
        'parent_comment_id': null,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      commentController.clear();
      fetchComments();
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/delete');

    final response = await http.patch(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> editComment(int commentId, String newContent) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> fetchPostLikeStatus() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}/like/status');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isPostLiked = data['data']['liked'];
      });
    }
  }

  Future<void> togglePostLike() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}/like');

    final response = await (isPostLiked
        ? http.delete(url, headers: {'Authorization': 'Bearer $token'})
        : http.post(url, headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      setState(() {
        isPostLiked = !isPostLiked;
        widget.post['like_count'] += isPostLiked ? 1 : -1;
      });
    }
  }

  Future<void> fetchAllCommentLikeStatus() async {
    final token = await storage.read(key: 'accessToken');
    for (final comment in comments) {
      final id = comment['id'];
      final url = Uri.parse('http://54.253.211.96:8000/api/comments/$id/like/status');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          commentLikeStatus[id] = data['data']['liked'];
        });
      }
    }
  }

  Future<void> toggleCommentLike(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/like');
    final liked = commentLikeStatus[commentId] ?? false;

    final response = await (liked
        ? http.delete(url, headers: {'Authorization': 'Bearer $token'})
        : http.post(url, headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> deletePost() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}');

    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
      }
    }
  }

  Future<void> editPost(String newContent) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.post['content'] = newContent;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다.')));
    }
  }

  void showEditDialog(int commentId, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await editComment(commentId, controller.text.trim());
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void showEditPostDialog(String currentContent) {
    editPostContentController.text = currentContent;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('게시글 수정'),
        content: TextField(controller: editPostContentController, maxLines: 5),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final text = editPostContentController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                await editPost(text);
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
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
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('재난 커뮤니티', style: TextStyle(color: Colors.black)),
        actions: [
          if (post['author']?['id'] == myUserId) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => showEditPostDialog(post['content'] ?? ''),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: deletePost,
            ),
          ]
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author']?['nickname'] ?? '알 수 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(parseTimeAgo(post['created_at']), style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isPostLiked ? Icons.favorite : Icons.favorite_border,
                        color: isPostLiked ? Colors.pink : Colors.grey,
                      ),
                      onPressed: togglePostLike,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post['image']),
                  ),
                const SizedBox(height: 12),
                Text(post['content'] ?? '', style: const TextStyle(fontSize: 16)),
                const Divider(height: 30),
                for (final comment in comments)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['author']?['nickname'] ?? '알 수 없음',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                parseTimeAgo(comment['created_at']),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(comment['content']),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (commentLikeStatus[comment['id']] ?? false)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: (commentLikeStatus[comment['id']] ?? false) ? Colors.pink : Colors.grey,
                                    ),
                                    onPressed: () => toggleCommentLike(comment['id']),
                                  ),
                                  Text('${comment['like_count']} likes', style: const TextStyle(fontSize: 12)),
                                  const Spacer(),
                                  if (comment['user_id'] == myUserId) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () => showEditDialog(comment['id'], comment['content']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18),
                                      onPressed: () async => await deleteComment(comment['id']),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = commentController.text.trim();
                      if (text.isNotEmpty) {
                        submitComment(text);
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.pink[200],
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AllPostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const AllPostDetailPage({super.key, required this.post});

  @override
  State<AllPostDetailPage> createState() => _AllPostDetailPageState();
}

class _AllPostDetailPageState extends State<AllPostDetailPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController editPostContentController = TextEditingController();
  List<dynamic> comments = [];
  bool isLoading = true;
  int? myUserId;
  bool isPostLiked = false;
  Map<int, bool> commentLikeStatus = {};

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchComments();
    fetchPostLikeStatus();
  }

  Future<void> fetchUserId() async {
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://54.253.211.96:8000/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          myUserId = data['data']['id'];
        });
      }
    }
  }

  Future<void> fetchComments() async {
    final postId = widget.post['id'];
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$postId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments = data;
          isLoading = false;
        });
        fetchAllCommentLikeStatus();
      }
    } catch (e) {
      print('댓글 API 오류: $e');
    }
  }

  Future<void> submitComment(String content) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post['id'],
        'content': content,
        'parent_comment_id': null,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      commentController.clear();
      fetchComments();
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/delete');

    final response = await http.patch(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> editComment(int commentId, String newContent) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> fetchPostLikeStatus() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}/like/status');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isPostLiked = data['data']['liked'];
      });
    }
  }

  Future<void> togglePostLike() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}/like');

    final response = await (isPostLiked
        ? http.delete(url, headers: {'Authorization': 'Bearer $token'})
        : http.post(url, headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      setState(() {
        isPostLiked = !isPostLiked;
        widget.post['like_count'] += isPostLiked ? 1 : -1;
      });
    }
  }

  Future<void> fetchAllCommentLikeStatus() async {
    final token = await storage.read(key: 'accessToken');
    for (final comment in comments) {
      final id = comment['id'];
      final url = Uri.parse('http://54.253.211.96:8000/api/comments/$id/like/status');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          commentLikeStatus[id] = data['data']['liked'];
        });
      }
    }
  }

  Future<void> toggleCommentLike(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$commentId/like');
    final liked = commentLikeStatus[commentId] ?? false;

    final response = await (liked
        ? http.delete(url, headers: {'Authorization': 'Bearer $token'})
        : http.post(url, headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      fetchComments();
    }
  }

  Future<void> deletePost() async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}');

    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
      }
    }
  }

  Future<void> editPost(String newContent) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${widget.post['id']}');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.post['content'] = newContent;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다.')));
    }
  }

  void showEditDialog(int commentId, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await editComment(commentId, controller.text.trim());
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void showEditPostDialog(String currentContent) {
    editPostContentController.text = currentContent;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('게시글 수정'),
        content: TextField(controller: editPostContentController, maxLines: 5),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final text = editPostContentController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                await editPost(text);
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
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
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('재난 커뮤니티', style: TextStyle(color: Colors.black)),
        actions: [
          if (post['author']?['id'] == myUserId) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => showEditPostDialog(post['content'] ?? ''),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: deletePost,
            ),
          ]
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author']?['nickname'] ?? '알 수 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(parseTimeAgo(post['created_at']), style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isPostLiked ? Icons.favorite : Icons.favorite_border,
                        color: isPostLiked ? Colors.pink : Colors.grey,
                      ),
                      onPressed: togglePostLike,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post['image']),
                  ),
                const SizedBox(height: 12),
                Text(post['content'] ?? '', style: const TextStyle(fontSize: 16)),
                const Divider(height: 30),
                for (final comment in comments)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['author']?['nickname'] ?? '알 수 없음',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                parseTimeAgo(comment['created_at']),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(comment['content']),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (commentLikeStatus[comment['id']] ?? false)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: (commentLikeStatus[comment['id']] ?? false) ? Colors.pink : Colors.grey,
                                    ),
                                    onPressed: () => toggleCommentLike(comment['id']),
                                  ),
                                  Text('${comment['like_count']} likes', style: const TextStyle(fontSize: 12)),
                                  const Spacer(),
                                  if (comment['user_id'] == myUserId) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () => showEditDialog(comment['id'], comment['content']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18),
                                      onPressed: () async => await deleteComment(comment['id']),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = commentController.text.trim();
                      if (text.isNotEmpty) {
                        submitComment(text);
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.pink[200],
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
