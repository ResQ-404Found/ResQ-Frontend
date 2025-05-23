import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'passwordresetemailsentpage.dart';

class PasswordResetEmailPage extends StatefulWidget {
  const PasswordResetEmailPage({super.key});

  @override
  State<PasswordResetEmailPage> createState() => _PasswordResetEmailPageState();
}

class _PasswordResetEmailPageState extends State<PasswordResetEmailPage> {
  final TextEditingController emailController = TextEditingController();

  Future<bool> sendResetEmail(String email) async {
    final uri = Uri.parse('http://54.79.229.221:8000/api/request-password-reset?email=$email');

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(data['message']);
        return true;
      } else {
        debugPrint('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '비밀번호 재설정',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ResQ에 가입했던 이메일을 입력해주세요.\n비밀번호 재설정 메일 보내드립니다.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              const Text("메일", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '가입한 메일을 입력하세요.',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 32),

              // 취소: 현재 화면 닫기 (Navigator.pop) , 비밀번호 재설정하기: 아래 로직 실행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("취소", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final email = emailController.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이메일을 입력해주세요.')),
                        );
                        return;
                      }

                      final success = await sendResetEmail(email);

                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PasswordResetEmailSentPage(email: email),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메일 전송에 실패했습니다. 다시 시도해주세요.')),
                        );
                      }
                    },
                    child: const Text("비밀번호 재설정하기"),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/* 전체 흐름 요약 
1. 이메일 입력
2. 비밀번호 재설정하기
3. 서버에 POST 요청
4. 성공 → 전송 완료 페이지 이동
    실패 → 오류 메시지 표시
*/