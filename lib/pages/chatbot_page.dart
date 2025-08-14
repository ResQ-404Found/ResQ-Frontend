import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // (현재 코드에선 사용 안 하지만 기존 유지)
import 'dart:io'; // (현재 코드에선 사용 안 하지만 기존 유지)
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'app_bottom_nav.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _loadingHistory = false; // ✅ 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _loadingHistory = true); // ✅ 시작 시 로딩 on

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
        Uri.parse('http://54.253.211.96:8000/api/chatbot/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> history = jsonDecode(response.body);
        final ordered = history.reversed.toList();
        if (!mounted) return;
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "안녕하세요 저는 재난 전문 챗봇입니다. 무엇을 도와드릴까요?",
          });
          for (final item in ordered) {
            _messages.add({"role": "user", "message": item['user_message']});
            _messages.add({"role": "bot", "message": item['bot_response']});
          }
        });
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
      if (mounted) setState(() => _loadingHistory = false); // ✅ 종료 시 로딩 off
    }
  }

  Future<String?> _getAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    return token;
  }

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
    });

    try {
      final response = await http.post(
        Uri.parse('http://54.253.211.96:8000/api/chatbot/chat'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"message": message}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response'] ?? '답변을 가져오지 못했습니다.';
        setState(() {
          _messages.add({"role": "bot", "message": botResponse});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "오류 발생: ${response.statusCode}",
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({"role": "bot", "message": "네트워크 오류: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ UserProfilePage처럼: 로딩 중엔 스피너 먼저 보여주기
    if (_loadingHistory) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
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
                ),
              ),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()), // ✅ 로딩 표시
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      );
    }

    // ✅ 로딩 끝나면 정상 화면
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
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
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                final messageWidget = Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: isUser
                        ? const EdgeInsets.fromLTRB(80, 20, 16, 5)
                        : const EdgeInsets.fromLTRB(16, 8, 60, 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? const Color(0xFF5DD194).withOpacity(0.2)
                              : Colors.redAccent.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );

                if (isUser) return messageWidget;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(bottom: 4)),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5E5E5E).withOpacity(0.4),
                                blurRadius: 3,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundImage:
                            AssetImage('lib/asset/chatbot_profile.png'),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '재난 전문 챗봇',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF454545),
                          ),
                        ),
                      ],
                    ),
                    messageWidget,
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
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
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
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
