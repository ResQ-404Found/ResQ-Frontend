import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WithdrawalConfirmationPage extends StatelessWidget {
  const WithdrawalConfirmationPage({super.key});

  Future<void> _deactivateUser(BuildContext context) async {
    const String apiUrl = 'http://54.252.128.243:8000/api/users/me/deactivate';
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 탈퇴 성공
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탈퇴 완료되었습니다'), duration: Duration(seconds: 2)),
        );
        await storage.deleteAll(); // 모든 토큰 삭제
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 로그인 화면으로
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 만료되었습니다. 다시 로그인해주세요')),
        );
        await storage.deleteAll();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('탈퇴 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '탈퇴하기',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '정말 탈퇴하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _deactivateUser(context),
                  child: const Text(
                    '예',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '아니오',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
