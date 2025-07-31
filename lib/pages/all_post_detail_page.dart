// 디자인 개선 + 댓글/대댓글 인터랙션 구현 + 댓글 입력 상태 복구 및 외부 터치 시 댓글 모드 복귀 + 댓글 좋아요 상태 반영 + 단일 댓글 카드 좋아요 버튼 추가 + 댓글 작성자 이름 표시 및 프로필 이미지 반영 + 게시글 제목 표시
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
  int? replyingToCommentId;

  List<dynamic> comments = [];
  bool isLoading = true;
  Set<int> likedCommentIds = {};
  String postAuthor = '';
  String postTitle = '';
  String postProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchPostData();
    fetchComments();

    commentFocusNode.addListener(() {
      if (!commentFocusNode.hasFocus) {
        setState(() => replyingToCommentId = null);
      }
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
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
        });
      }
    } catch (_) {}
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
    } catch (e) {
      print('댓글 API 오류: $e');
    }
  }

  Future<void> _checkIfLiked(dynamic comment) async {
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse(
      'http://54.253.211.96:8000/api/comments/${comment['id']}/like/status',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final liked = data['data']['liked'] ?? false;
        if (liked) {
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
      'http://54.253.211.96:8000/api/comments/$commentId/like',
    );

    final isLiked = likedCommentIds.contains(commentId);
    final response =
        isLiked
            ? await http.delete(
              url,
              headers: {'Authorization': 'Bearer $token'},
            )
            : await http.post(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      setState(() {
        if (isLiked) {
          likedCommentIds.remove(commentId);
        } else {
          likedCommentIds.add(commentId);
        }
      });
      fetchComments();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => replyingToCommentId = null);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            '게시글',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildPostCard(),
                          const SizedBox(height: 20),
                          const Text(
                            '댓글',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...comments.map<Widget>((c) => _buildCommentItem(c)),
                          const SizedBox(height: 10),
                        ],
                      ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        focusNode: commentFocusNode,
                        decoration: InputDecoration(
                          hintText:
                              replyingToCommentId != null
                                  ? '대댓글을 입력하세요.'
                                  : '댓글을 입력하세요.',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
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
                          submitComment(text, parentId: replyingToCommentId);
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
    );
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
                backgroundImage:
                    hasProfileImage
                        ? NetworkImage(postProfileImageUrl)
                        : const AssetImage('lib/asset/sample_profile.jpg')
                            as ImageProvider,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postAuthor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    parseTimeAgo(widget.post['created_at']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            postTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.post['post_imageURLs'] != null &&
              widget.post['post_imageURLs'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.post['post_imageURLs'][0],
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Text('이미지를 불러올 수 없습니다.'),
              ),
            ),
          if (widget.post['post_imageURLs'] != null &&
              widget.post['post_imageURLs'].isNotEmpty)
            const SizedBox(height: 12),
          Text(
            widget.post['content'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(dynamic comment, {int indent = 0}) {
    final replies = comment['replies'] ?? [];
    final isLiked = likedCommentIds.contains(comment['id']);
    final isReply = indent > 0;
    final authorName = comment['author']?['username'] ?? '익명';

    return Padding(
      padding: EdgeInsets.only(
        left: indent.toDouble(),
        bottom: isReply ? 6 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isReply ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isReply)
                      const Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      parseTimeAgo(comment['created_at']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(left: isReply ? 16.0 : 0.0),
                  child: Text(
                    comment['content'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                      onPressed: () => toggleLike(comment['id']),
                    ),
                    Text(
                      '${comment['like_count']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (!isReply)
                      TextButton(
                        onPressed: () {
                          setState(() => replyingToCommentId = comment['id']);
                          FocusScope.of(context).requestFocus(commentFocusNode);
                        },
                        child: const Text(
                          '댓글 달기',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          for (final reply in replies)
            _buildCommentItem(reply, indent: indent + 12),
        ],
      ),
    );
  }
}
