import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WithdrawalConfirmationPage extends StatelessWidget {
  const WithdrawalConfirmationPage({super.key});

  Future<void> _deactivateUser(BuildContext context) async {
    const String apiUrl = 'http://54.253.211.96:8000/api/users/delete';
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
      // backgroundColor: const Color(0xFFFF3535),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF3434), // 위쪽 진한 빨강
              Color(0xFFFF9898), // 아래쪽 연한 분홍
            ],
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.only(top: 0), // 위쪽 여백 추가 (조정 가능)
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24), // 좌우 마진 추가하여 너비 제한
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24), // 안쪽 여백 조정 (이미지에 맞게 상하단 여백 증가)
            decoration: BoxDecoration(
              color: Colors.white, // 내부 배경은 흰색
              borderRadius: BorderRadius.circular(20), // 둥근 모서리 (이미지에 맞게 더 둥글게)
              boxShadow: [ // 흰색 네모에 살짝 그림자 추가
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 5), // 그림자의 위치 설정
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 세로 크기를 최소화
              mainAxisAlignment: MainAxisAlignment.start, // 위쪽에 배치
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red.shade100,
                  child: Icon(
                    Icons.person_off_rounded,
                    color: Colors.red.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '정말 탈퇴하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '탈퇴 시 모든 포인트는 삭제됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '이 작업은 되돌릴 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D3D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _deactivateUser(context),
                      child: const Text(
                        '예, 탈퇴하겠습니다',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '아니오, 계속 이용하겠습니다',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),);
  }
}
