import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'app_bottom_nav.dart';
import 'chatbot_page.dart';

class CounselingChatbotPage extends StatefulWidget {
  const CounselingChatbotPage({super.key});
  @override
  State<CounselingChatbotPage> createState() => _CounselingChatbotPageState();
}

class _CounselingChatbotPageState extends State<CounselingChatbotPage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _loadingHistory = false;
  bool _isTyping = false;

  static const String baseUrl = 'http://54.253.211.96:8000';
  static const String historyPath = '/api/counseling/history';
  static const String chatPath = '/api/counseling/chat';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _loadingHistory = true);
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      if (mounted) setState(() => _loadingHistory = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$historyPath'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> history = jsonDecode(response.body);
        final ordered = history.reversed.toList();
        if (!mounted) return;
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "안녕하세요, 심리상담 챗봇입니다. 편하게 고민을 남겨주세요.",
          });
          for (final item in ordered) {
            _messages.add({"role": "user", "message": item['user_message']});
            _messages.add({"role": "bot", "message": item['bot_response']});
          }
        });
        _jumpToBottom();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('기록 불러오기 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 기록 불러오기 오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<String?> _getAccessToken() async => _storage.read(key: 'accessToken');

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      return;
    }

    setState(() {
      _messages.add({"role": "user", "message": message});
      _messageController.clear();
      _isTyping = true;
    });
    _jumpToBottom();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$chatPath'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"message": message, "mode": "counseling"}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response'] ?? '답변을 가져오지 못했습니다.';
        setState(() {
          _messages.add({"role": "bot", "message": botResponse});
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "message": "오류 발생: ${response.statusCode}"});
          _isTyping = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({"role": "bot", "message": "네트워크 오류: $e"});
        _isTyping = false;
      });
    }
    _jumpToBottom();
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  PreferredSizeWidget _styledAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Stack(
        children: [
          Container(height: 60, color: Colors.white),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '챗봇',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF353535),
                  ),
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _chipBar(isCounseling: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipBar({required bool isCounseling}) {
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFE6EA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.pinkAccent : const Color(0xFFE6E6E6),
              width: 1.2,
            ),
            boxShadow: selected
                ? [BoxShadow(color: Colors.pinkAccent.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.pinkAccent : const Color(0xFF7B7B7B),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip('재난', !isCounseling, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotPage()),
          );
        }),
        const SizedBox(width: 8),
        chip('심리상담', isCounseling, () {
        }),
      ],
    );
  }

  Widget _bubble({required String text, required bool isUser}) {
    final Color userBg = const Color(0xFFE7F5EC); // 민트
    final Color botBg = const Color(0xFFFFE6EA);  // 연핑크
    final Color shadowColor = isUser ? const Color(0xFF5DD194) : Colors.pinkAccent;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isUser ? const EdgeInsets.fromLTRB(80, 14, 16, 6) : const EdgeInsets.fromLTRB(16, 10, 80, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? userBg : botBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.16), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Text(text, style: const TextStyle(fontSize: 15.0, height: 1.35)),
      ),
    );
  }

  Widget _botMessage(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: const Color(0xFF5E5E5E).withOpacity(0.35), blurRadius: 3, offset: const Offset(0, 0)),
              ]),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('lib/asset/chatbot_profile.png'),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '심리상담 챗봇',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF454545)),
            ),
          ],
        ),
        _bubble(text: text, isUser: false),
      ],
    );
  }

  Widget _typingBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: const Color(0xFF5E5E5E).withOpacity(0.35), blurRadius: 3, offset: const Offset(0, 0)),
              ]),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('lib/asset/chatbot_profile.png'),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 80, 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6EA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.16), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const _AnimatedDots(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHistory) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _styledAppBar(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _styledAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) return _typingBubble();
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return isUser ? _bubble(text: msg['message'] ?? '', isUser: true) : _botMessage(msg['message'] ?? '');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E6E6)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        contentPadding: EdgeInsets.only(left: 8),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _a1;
  late final Animation<double> _a2;
  late final Animation<double> _a3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _a1 = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6));
    _a2 = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8));
    _a3 = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> a) {
    return FadeTransition(
      opacity: a,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: CircleAvatar(radius: 4.5, backgroundColor: Color(0xFFB16C7A)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [_dot(_a1), _dot(_a2), _dot(_a3)]);
  }
}
