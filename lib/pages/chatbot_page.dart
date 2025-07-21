import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final List<Map<String, String>> _messages =
  []; // {"role": "user"/"bot", "message": "내용"}

  Future<String?> _getAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    print("읽은 accessToken: $token");
    return token;
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
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
      setState(() {
        _messages.add({"role": "bot", "message": "네트워크 오류: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '챗봇',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                final messageWidget = Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                    isUser
                        ? const EdgeInsets.fromLTRB(
                      80,
                      20,
                      0,
                      5,
                    ) // 사용자: 오른쪽 정렬, 왼쪽 여백 추가
                        : const EdgeInsets.fromLTRB(10, 4, 80, 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );

                if (isUser) {
                  return messageWidget;
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(bottom: 4)),
                      Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 16,
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '이름',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      messageWidget,
                    ],
                  );
                }
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
              ),
              IconButton(
                icon: Icon(Icons.chat, color: Colors.black),
                iconSize: 32,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.groups, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  Navigator.pushNamed(context, '/community');
                },
              ),
              IconButton(
                icon: Icon(Icons.emergency_share, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  Navigator.pushNamed(context, '/disastermenu');
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  Navigator.pushNamed(context, '/user');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}