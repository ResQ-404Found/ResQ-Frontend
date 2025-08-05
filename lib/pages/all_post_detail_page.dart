
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
  final FocusNode commentFocusNode = FocusNode();
  final TextEditingController replyController = TextEditingController();
  int? replyingToCommentId;

  List<dynamic> comments = [];
  bool isLoading = true;
  Set<int> likedCommentIds = {};
  String postAuthor = '';
  String postTitle = '';
  String postProfileImageUrl = '';
  bool postLiked = false;
  int postLikeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPostData();
    fetchComments();
    fetchPostLikeStatus();
  }

  @override
  void dispose() {
    commentController.dispose();
    replyController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('게시글', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPostCard(),
                const SizedBox(height: 20),
                Text('댓글 ${comments.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (comments.isEmpty)
                  const Center(child: Text('댓글이 없습니다'))
                else
                  ...comments.map((c) => _buildCommentItem(c)),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      focusNode: commentFocusNode,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요.',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.red),
                    onPressed: () {
                      final text = commentController.text.trim();
                      if (text.isNotEmpty) {
                        submitComment(text);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: comment['author']['profile_image_url'] != null
                          ? NetworkImage(comment['author']['profile_image_url'])
                          : const AssetImage('lib/asset/sample_profile.jpg') as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 8),
                    Text(comment['author']['username'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(comment['content'] ?? ''),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        likedCommentIds.contains(comment['id'])
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 18,
                      ),
                      onPressed: () => toggleLike(comment['id']),
                    ),
                    Text('${comment['like_count']}'),
                    TextButton(
                      onPressed: () => setState(() {
                        replyingToCommentId = comment['id'];
                        replyController.text = '@${comment['author']['username']} ';
                      }),
                      child: const Text('댓글 달기',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                if (replyingToCommentId == comment['id'])
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 40.0, right: 8.0), // ← 오른쪽으로 이동
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ← 내부 padding 줄임
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // ← 살짝 둥글게
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              style: const TextStyle(fontSize: 14), // ← 텍스트 조금 작게
                              decoration: const InputDecoration(
                                hintText: '대댓글을 입력하세요.',
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero, // ← 버튼 패딩 없애기
                            constraints: const BoxConstraints(), // ← 크기 줄이기
                            icon: const Icon(Icons.send, color: Colors.grey, size: 18), // ← 작게
                            onPressed: () {
                              final text = replyController.text.trim();
                              if (text.isNotEmpty) {
                                submitComment(text, parentId: comment['id']);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ...(comment['replies'] ?? []).map((reply) => Padding(
          padding: const EdgeInsets.only(left: 30),
          child: _buildCommentItem(reply),
        ))
      ],
    );
  }

  Future<void> fetchPostData() async {
    final token = await storage.read(key: 'accessToken');
    final postId = widget.post['id'];
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          postAuthor = data['author']?['username'] ?? '';
          postProfileImageUrl = data['author']?['profile_imageURL'] ?? '';
          postTitle = data['title'] ?? '';
          postLikeCount = data['like_count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchPostLikeStatus() async {
    final token = await storage.read(key: 'accessToken');
    final postId = widget.post['id'];
    final url = Uri.parse(
        'http://54.253.211.96:8000/api/posts/$postId/like/status');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          postLiked = data['data']['liked'];
        });
      }
    } catch (_) {}
  }

  Future<void> togglePostLike() async {
    final token = await storage.read(key: 'accessToken');
    final postId = widget.post['id'];
    final url = Uri.parse('http://54.253.211.96:8000/api/posts/$postId/like');

    try {
      final isLiked = postLiked;
      final response = isLiked
          ? await http.delete(url, headers: {'Authorization': 'Bearer $token'})
          : await http.post(url, headers: {'Authorization': 'Bearer $token'});

      print('좋아요 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          postLiked = !postLiked;
          postLikeCount += postLiked ? 1 : -1;
        });
      } else {
        print('좋아요 실패: ${response.body}');
      }
    } catch (e) {
      print('좋아요 요청 오류: $e');
    }
  }

  Future<void> fetchComments() async {
    final postId = widget.post['id'];
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('http://54.253.211.96:8000/api/comments/$postId');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments = data;
          isLoading = false;
        });

        for (final comment in data) {
          _checkIfLiked(comment);
          for (final reply in comment['replies'] ?? []) {
            _checkIfLiked(reply);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _checkIfLiked(dynamic comment) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse(
        'http://54.253.211.96:8000/api/comments/${comment['id']}/like/status');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['liked']) {
          setState(() {
            likedCommentIds.add(comment['id']);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> submitComment(String content, {int? parentId}) async {
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
        'parent_comment_id': parentId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      commentController.clear();
      setState(() => replyingToCommentId = null);
      fetchComments();
    }
  }

  Future<void> toggleLike(int commentId) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse(
        'http://54.253.211.96:8000/api/comments/$commentId/like');

    final isLiked = likedCommentIds.contains(commentId);
    final response = isLiked
        ? await http.delete(url, headers: {'Authorization': 'Bearer $token'})
        : await http.post(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      setState(() {
        if (isLiked) {
          likedCommentIds.remove(commentId);
        } else {
          likedCommentIds.add(commentId);
        }
        for (var comment in comments) {
          if (comment['id'] == commentId) {
            comment['like_count'] += isLiked ? -1 : 1;
          }
          for (var reply in comment['replies'] ?? []) {
            if (reply['id'] == commentId) {
              reply['like_count'] += isLiked ? -1 : 1;
            }
          }
        }
      });
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

  Widget _buildPostCard() {
    final hasProfileImage = postProfileImageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: hasProfileImage
                    ? NetworkImage(postProfileImageUrl)
                    : const AssetImage(
                    'lib/asset/sample_profile.jpg') as ImageProvider,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postAuthor,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(parseTimeAgo(widget.post['created_at']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(postTitle, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (widget.post['post_imageURLs'] != null &&
              widget.post['post_imageURLs'].isNotEmpty)
            Column(
              children: (widget.post['post_imageURLs'] as List)
                  .map<Widget>((url) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url,
                          errorBuilder: (context, error,
                              stackTrace) => const SizedBox.shrink()),
                    ),
                  ))
                  .toList(),
            ),
          const SizedBox(height: 12),
          Text(widget.post['content'] ?? '',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: togglePostLike,
                child: Row(
                  children: [
                    Icon(postLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                        '$postLikeCount', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.comment, size: 18, color: Colors.blue),
              const SizedBox(width: 4),
              Text('${comments.length}', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}