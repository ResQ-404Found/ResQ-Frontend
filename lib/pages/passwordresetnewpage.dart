import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetNewPage extends StatefulWidget {
  final String token;

  const PasswordResetNewPage({super.key, required this.token});

  @override
  State<PasswordResetNewPage> createState() => _PasswordResetNewPageState();
}

class _PasswordResetNewPageState extends State<PasswordResetNewPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showSnack('모든 필드를 입력해주세요.');
      return;
    }

    if (newPassword != confirmPassword) {
      showSnack('비밀번호가 일치하지 않습니다.');
      return;
    }

    final uri = Uri.parse('http://54.79.229.221:8000/api/reset-password');
    final body = jsonEncode({
      'password': newPassword,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        showSnack('비밀번호가 성공적으로 재설정되었습니다.');
        Navigator.popUntil(context, ModalRoute.withName('/initial'));
      } else {
        showSnack('재설정 실패: ${response.statusCode}');
      }
    } catch (e) {
      showSnack('오류 발생: $e');
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('비밀번호 재설정', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TextFieldTitle(text: "새 비밀번호"),
            TextField(
              obscureText: true,
              controller: newPasswordController,
              decoration: InputDecoration(
                hintText: '새 비밀번호를 입력하세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            const TextFieldTitle(text: "새 비밀번호 재입력"),
            TextField(
              obscureText: true,
              controller: confirmPasswordController,
              decoration: InputDecoration(
                hintText: '새 비밀번호를 한 번 더 입력하세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: resetPassword,
              child: const Text('비밀번호 재설정하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFieldTitle extends StatelessWidget {
  final String text;
  const TextFieldTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


/* 전채흐름 요약 

1. 사용자 이메일 인증 토큰과 함께 진입
2. 새 비밀번호 입력 + 재입력
3. 비밀번호 재설정 버튼 클릭
4. 서버에 POST 요청 (Bearer 토큰 포함)
5. 성공 → 초기화면 이동] or [실패 → 오류 메시지]

*/
