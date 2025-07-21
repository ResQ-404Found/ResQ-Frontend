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
                            radius: 16,
                            backgroundImage: AssetImage('lib/asset/chatbot_profile.png'),
                            backgroundColor: Colors.transparent,
                          ),

                          SizedBox(width: 8),
                          Text(
                            '재난 전문 챗봇',
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색
              blurRadius: 10, // 퍼짐 정도
              offset: Offset(0, -2), // 위쪽으로 살짝 그림자
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Container에서 색 처리했으므로 투명
          elevation: 0, // 내부 elevation 제거
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/map');
                break;
              case 1:
                break;
              case 2:
                Navigator.pushNamed(context, '/community');
                break;
              case 3:
                Navigator.pushNamed(context, '/disastermenu');
                break;
              case 4:
                Navigator.pushNamed(context, '/user');
                break;
            }
          },
          selectedItemColor: Colors.redAccent, // 선택된 아이콘 색
          unselectedItemColor: Colors.grey[300], // 비선택 아이콘 색
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 30),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)),
              label: '재난메뉴',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}